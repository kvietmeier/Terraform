## Firewall rule to open eveything up for testing.

**This is a really, really, BAD Idea!  Use only for testing.**

---

*Code:*

```terraform

resource "google_compute_firewall" "allow_all" {
  name    = "allow-all-traffic"
  network = "default" # Replace with your network name if different

  direction = "INGRESS"
  priority  = 10

  source_ranges = ["0.0.0.0/0"] # Allow traffic from all IPs (external and internal)

  allow {
    protocol = "all" # Allow all protocols
  }
}
```

---

#### Author/s

* **Karl Vietmeier**

#### License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

* None so far other than the many good examples out there.
