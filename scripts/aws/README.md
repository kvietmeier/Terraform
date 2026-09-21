# scripts/aws/

AWS-specific helpers belong here.

## Related

- Linux lab bootstrap → [`../cloud-init/`](../cloud-init/)
- Legacy AWS cloud-init YAML → [`../cloud-init/deprecated/`](../cloud-init/deprecated/)

## Scripts

| Script | Purpose |
|--------|---------|
| [`launch-lab-client.sh`](launch-lab-client.sh) | Launch an Ubuntu lab client via `aws ec2 run-instances` (requires `SUBNET_ID`, `SG_ID`, `KEY_NAME`) |

