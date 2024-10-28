Here is an improved version of your markdown document with grammar and clarity adjustments:
# SSO
[sso.simple.org](https://sso.simple.org/)

This is the single sign-on (SSO) service for internal applications, managed using [Keycloak](https://github.com/keycloak/keycloak). Please refer to the [Keycloak documentation](https://www.keycloak.org/docs/latest/server_admin/) to understand key concepts.

## Deployment
Keycloak is deployed using a Helm chart in the `systems-production` cluster. Configuration files can be found [here](../k8s/environments/systems-production/values/keycloak.yaml). Additionally, a custom wrapper with optimized default settings has been created and can be accessed [here](../k8s/manifests/keycloak/).

## Integrations
- **Grafana:** All Grafana instances are integrated with Keycloak for SSO. Detailed integration documentation is available [here](https://grafana.com/docs/grafana/latest/setup-grafana/configure-security/configure-authentication/keycloak/).
- **ArgoCD:** ArgoCD supports Keycloak integration, and the Sandbox environment’s ArgoCD is already configured. Documentation for the integration process can be found [here](https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/keycloak/).
- **AWS:** AWS can also be configured for SSO with Keycloak. Details from our preliminary testing (spike) are documented [here](https://docs.google.com/document/d/17MYJODA5DZcBLeFQMM2Uj1bbtdutcFOfxtnu2TteKu8).
- **Metabase:** The community version of Metabase does not support SSO.
- **Other Applications:** Further exploration is needed to evaluate if Keycloak can be used with other internal applications.

## Users, Roles, Groups, etc.
Currently, we are using the default `master` realm.

- **Groups:**
  - `simple_team`: Backend developers
  - `ArgoCDAdmins`: Admin access for ArgoCD
- **Roles:**
  - `grafana_admin`
  - `grafana_editor`
- **Users:** Users are managed via the Keycloak Admin Console.

**Note:** As we expand the types of users and applications, we may revisit and revise our approach to managing groups and roles to better align with our needs.
