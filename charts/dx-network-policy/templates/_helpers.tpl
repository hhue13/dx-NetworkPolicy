{{/*
Expand the name of the chart.
*/}}
{{- define "dx-network-policy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dx-network-policy.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dx-network-policy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dx-network-policy.labels" -}}
helm.sh/chart: {{ include "dx-network-policy.chart" . }}
{{ include "dx-network-policy.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dx-network-policy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dx-network-policy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
Create a network policy to allow access for a port from a specific app
*/}}
{{- define "dx-network-policy.crossNamespaceAccessPerNamespace" -}}
{{- $top := index . 0 }}
{{- $port := index . 1 }}
{{- $namespace := index . 2 }}
{{- $namespaceApp := index . 3 }}
{{- $fromNamespace := index . 4 }}
{{- $fromNamespaceApp := index . 5 }}
{{- printf "\n### port:  %s"  ($port | quote) }}
{{- printf "\n### namespace:  %s\tnamespaceApp: %s"  $namespace $namespaceApp }}
{{- printf "\n### fromNamespace:  %s\tfromNamespaceApp: %s"  $fromNamespace $fromNamespaceApp }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: "allow-{{ $port }}-from-{{ $fromNamespace }}"
  namespace: {{ $top.Release.Namespace }}
  labels:
  {{- include "dx-network-policy.labels" $top | nindent 4 }}
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app: {{ $namespaceApp }}
  ingress:
    - from:
      - namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: {{ $fromNamespace }}
        podSelector:
          matchLabels:
            app: {{ $fromNamespaceApp }}
      ports:
        - port: {{ $port }}
          protocol: TCP
{{- end }}


{{/*
Create a network policy to allow cross-namespace entry for a specific port
*/}}
{{- define "dx-network-policy.crossNamespaceAccess" -}}
{{- $top := index . 0 }}
{{- $def := index . 1 }}
{{- printf "\n### port:  %s"  ($def.port | quote) }}
{{- printf "\n### fromNs.name:  %s\tfromNs.app: %s"  $def.fromNs.name $def.fromNs.app }}
{{- include "dx-network-policy.crossNamespaceAccessPerNamespace" (list $top $def.port $def.toNs.name $def.toNs.app $def.fromNs.name $def.fromNs.app) }}
{{- end }}