{{/*
Service name
*/}}
{{- define "consumer.name" -}}
consumer
{{- end }}

{{/*
Labels used for Deployment/Service/etc.
*/}}
{{- define "consumer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "consumer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "consumer.labels" -}}
{{ include "consumer.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}