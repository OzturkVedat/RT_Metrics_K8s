{{/*
Service name
*/}}
{{- define "producer.name" -}}
producer
{{- end }}

{{/*
Labels used for Deployment/Service/etc.
*/}}
{{- define "producer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "producer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "producer.labels" -}}
{{ include "producer.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}