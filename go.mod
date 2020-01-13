module github.com/baarde/cert-manager-webhook-ovh

go 1.12

require (
	github.com/jetstack/cert-manager v0.12.0
	github.com/ovh/go-ovh v0.0.0-20181109152953-ba5adb4cf014
	k8s.io/api v0.0.0-20191114100352-16d7abae0d2a
	k8s.io/apiextensions-apiserver v0.0.0-20191114105449-027877536833
	k8s.io/apimachinery v0.0.0-20191028221656-72ed19daf4bb
	k8s.io/client-go v0.0.0-20191114101535-6c5935290e33
)

replace github.com/prometheus/client_golang => github.com/prometheus/client_golang v0.9.4
