package appshield.kubernetes.KSV036

import data.lib.kubernetes
import data.lib.utils

__rego_metadata__ := {
	"id": "KSV036",
	"title": "Protecting Pod service account tokens",
	"version": "v1.0.0",
	"severity": "MEDIUM",
	"type": "Kubernetes Security Check",
	"description": "ensure that Pod specifications disable the secret token being mounted by setting automountServiceAccountToken: false",
	"recommended_actions": "Remove 'container.apparmor.security.beta.kubernetes.io' annotation or set it to 'runtime/default'.",
	"url": "https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/#serviceaccount-admission-controller",
}

deny[res] {
	mountServiceAccountToken(input.spec)
	msg := kubernetes.format(sprintf("Container of %s '%s' should set 'spec.automountServiceAccountToken' to false", [kubernetes.kind, kubernetes.name]))

	res := {
		"msg": msg,
		"id": __rego_metadata__.id,
		"title": __rego_metadata__.title,
		"severity": __rego_metadata__.severity,
		"type": __rego_metadata__.type,
	}
}

mountServiceAccountToken(spec) {
	has_key(spec, "automountServiceAccountToken")
	spec.automountServiceAccountToken == true
}

# if there is no automountServiceAccountToken spec, check on volumeMount in containers. Service Account token is mounted on /var/run/secrets/kubernetes.io/serviceaccount
mountServiceAccountToken(spec) {
	not has_key(spec, "automountServiceAccountToken")
	"/var/run/secrets/kubernetes.io/serviceaccount" == kubernetes.containers[_].volumeMounts[_].mountPath
}

has_key(x, k) {
	_ = x[k]
}
