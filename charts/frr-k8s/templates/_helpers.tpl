{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "frrk8s.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "frrk8s.fullname" -}}
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
{{- define "frrk8s.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "frrk8s.labels" -}}
helm.sh/chart: {{ include "frrk8s.chart" . }}
{{ include "frrk8s.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "frrk8s.selectorLabels" -}}
app.kubernetes.io/name: {{ include "frrk8s.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the frrk8s service account to use
*/}}
{{- define "frrk8s.serviceAccountName" -}}
{{- if .Values.frrk8s.serviceAccount.create }}
{{- default (printf "%s-controller" (include "frrk8s.fullname" .)) .Values.frrk8s.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.frrk8s.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Returns a string representing the Kubernetes platform e.g. openshift, microk8s, tanzu, etc
*/}}
{{- define "frrk8s.k8sPlatform" }}
  {{- if ( dig "global" "k8sPlatform" false .Values.AsMap ) }}
    {{- .Values.global.k8sPlatform }}
  {{- else }}
    {{- $nodes := lookup "v1" "Node" "" "" }}
    {{- if $nodes }}
      {{- $node := first $nodes.items }}
      {{- if ( dig "metadata" "labels" "node.openshift.io/os_id" false $node ) }}
        {{- "openshift" }}
      {{- else if ( dig "metadata" "labels" "microk8s.io/cluster" false $node ) }}
        {{- "microk8s" }}
      {{- else if ( dig "metadata" "labels" "eks.amazonaws.com/nodegroup" false $node ) }}
        {{- "eks" }}
      {{- else if ( dig "metadata" "labels" "node.cluster.x-k8s.io/esxi-host" false $node ) }}
        {{- "tanzu" }}
      {{- else }}
        {{- "kubernetes" }}
      {{- end }}
    {{- else }}
        {{- "kubernetes" }}
    {{- end }}
  {{- end }}
{{- end }}
