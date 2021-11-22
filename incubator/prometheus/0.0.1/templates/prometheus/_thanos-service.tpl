{{- define "prometheus.prometheus.thanos.service" -}}
{{- if and .Values.prometheus.enabled .Values.prometheus.thanos.create }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ template "kube-prometheus.prometheus.fullname" . }}-thanos
  namespace: {{ .Release.Namespace }}
  labels: {{- include "kube-prometheus.prometheus.labels" . | nindent 4 }}
    app.kubernetes.io/subcomponent: thanos
  {{- if .Values.prometheus.thanos.service.annotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.thanos.service.annotations "context" $) | nindent 4 }}
  {{- end }}
spec:
  type: {{ .Values.prometheus.thanos.service.type }}
  {{- if and .Values.prometheus.thanos.service.loadBalancerIP (eq .Values.prometheus.thanos.service.type "LoadBalancer") }}
  loadBalancerIP: {{ .Values.prometheus.thanos.service.loadBalancerIP }}
  {{- end }}
  {{- if and (eq .Values.prometheus.thanos.service.type "LoadBalancer") .Values.prometheus.thanos.service.loadBalancerSourceRanges }}
  {{- with .Values.prometheus.thanos.service.loadBalancerSourceRanges }}
  loadBalancerSourceRanges: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- end }}
  {{- if and (eq .Values.prometheus.thanos.service.type "ClusterIP") .Values.prometheus.thanos.service.clusterIP }}
  clusterIP: {{ .Values.prometheus.thanos.service.clusterIP }}
  {{- end }}
  ports:
    - name: grpc
      port: {{ .Values.prometheus.thanos.service.port }}
      targetPort: grpc
      protocol: TCP
      {{- if and .Values.prometheus.thanos.service.nodePort (or (eq .Values.prometheus.thanos.service.type "NodePort") (eq .Values.prometheus.thanos.service.type "LoadBalancer")) }}
      nodePort: {{ .Values.prometheus.thanos.service.nodePort }}
      {{- end }}
    {{- if .Values.prometheus.thanos.service.extraPorts }}
    {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.thanos.service.extraPorts "context" $) | nindent 4 }}
    {{- end }}
  selector:
    app.kubernetes.io/name: prometheus
    prometheus: {{ template "kube-prometheus.prometheus.fullname" . }}
{{- end }}
{{- end }}
