### README.md Template

Terraform templates for creating infrastructure in GCP.

#### Notes

Put Notes Here

---

#### Code Samples

PowerShell

```powershell
. '<drive>:\.hideme\somesecretstuff.ps1'
```

Set the variables:

```powershell
$env:
```

Terraform:

```terraform
resource "google_compute_firewall" "allow_all_ports" {
  name    = "allow-all-ports"
  network = "default"                     # Change if using a different network

  allow {
    protocol = "tcp"
    ports =  ["0-65535"]
  }
```






#### My code is Built With

* [Visual Studio Code](https://code.visualstudio.com/) - Editor
* [Terraform](https://www.terraform.io/) - Terraform

#### All run under PowerShell on Windows 11

* [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/) - Console

#### Author/s

* **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

* None so far other than the many good examples out there.
