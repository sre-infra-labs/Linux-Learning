# Error/Fix: This system is registered with an entitlement server, but is not receiving updates. You can use subscription-manager to assign subscriptions
## Fix
```
sudo subscription-manager clean

sudo subscription-manager register --username="<your_redhat_username>" --password="<your_redhat_password>"

sudo subscription-manager attach --auto

sudo subscription-manager status
sudo dnf clean all
sudo dnf install consul
```