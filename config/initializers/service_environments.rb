ALL_ENVS = {
  dev: {
    name: 'Development',
    protocol: 'https://',
    url_root: 'apps.cloud-platform-live-0.k8s.integration.dsd.io'
  },
  staging: {
    name: 'Staging',
    protocol: 'https://',
    url_root: 'apps.cloud-platform-live-0.k8s.integration.dsd.io'
  },
  production: {
    name: 'Production',
    protocol: 'https://',
    url_root: 'apps.cloud-platform-live-0.k8s.integration.dsd.io'
  }
}

Rails.configuration.x.service_environments = ALL_ENVS
