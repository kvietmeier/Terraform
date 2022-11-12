# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function k() { & kubectl $args }
function ksys() { & kubectl --namespace=kube-system $args }
function ka() { & kubectl apply --recursive -f $args }
function ksysa() { & kubectl --namespace=kube-system apply --recursive -f $args }
function kak() { & kubectl apply -k $args }
function kk() { & kubectl kustomize $args }
function kex() { & kubectl exec -i -t $args }
function ksysex() { & kubectl --namespace=kube-system exec -i -t $args }
function klo() { & kubectl logs -f $args }
function ksyslo() { & kubectl --namespace=kube-system logs -f $args }
function klop() { & kubectl logs -f -p $args }
function ksyslop() { & kubectl --namespace=kube-system logs -f -p $args }
function kp() { & kubectl proxy $args }
function kpf() { & kubectl port-forward $args }
function kg() { & kubectl get $args }
function ksysg() { & kubectl --namespace=kube-system get $args }
function kd() { & kubectl describe $args }
function ksysd() { & kubectl --namespace=kube-system describe $args }
function krm() { & kubectl delete $args }
function ksysrm() { & kubectl --namespace=kube-system delete $args }
function krun() { & kubectl run --rm --restart=Never --image-pull-policy=IfNotPresent -i -t $args }
function ksysrun() { & kubectl --namespace=kube-system run --rm --restart=Never --image-pull-policy=IfNotPresent -i -t $args }
function kgpo() { & kubectl get pods $args }
function ksysgpo() { & kubectl --namespace=kube-system get pods $args }
function kdpo() { & kubectl describe pods $args }
function ksysdpo() { & kubectl --namespace=kube-system describe pods $args }
function krmpo() { & kubectl delete pods $args }
function ksysrmpo() { & kubectl --namespace=kube-system delete pods $args }
function kgdep() { & kubectl get deployment $args }
function ksysgdep() { & kubectl --namespace=kube-system get deployment $args }
function kddep() { & kubectl describe deployment $args }
function ksysddep() { & kubectl --namespace=kube-system describe deployment $args }
function krmdep() { & kubectl delete deployment $args }
function ksysrmdep() { & kubectl --namespace=kube-system delete deployment $args }
function kgsvc() { & kubectl get service $args }
function ksysgsvc() { & kubectl --namespace=kube-system get service $args }
function kdsvc() { & kubectl describe service $args }
function ksysdsvc() { & kubectl --namespace=kube-system describe service $args }
function krmsvc() { & kubectl delete service $args }
function ksysrmsvc() { & kubectl --namespace=kube-system delete service $args }
function kging() { & kubectl get ingress $args }
function ksysging() { & kubectl --namespace=kube-system get ingress $args }
function kding() { & kubectl describe ingress $args }
function ksysding() { & kubectl --namespace=kube-system describe ingress $args }
function krming() { & kubectl delete ingress $args }
function ksysrming() { & kubectl --namespace=kube-system delete ingress $args }
function kgcm() { & kubectl get configmap $args }
function ksysgcm() { & kubectl --namespace=kube-system get configmap $args }
function kdcm() { & kubectl describe configmap $args }
function ksysdcm() { & kubectl --namespace=kube-system describe configmap $args }
function krmcm() { & kubectl delete configmap $args }
function ksysrmcm() { & kubectl --namespace=kube-system delete configmap $args }
function kgsec() { & kubectl get secret $args }
function ksysgsec() { & kubectl --namespace=kube-system get secret $args }
function kdsec() { & kubectl describe secret $args }
function ksysdsec() { & kubectl --namespace=kube-system describe secret $args }
function krmsec() { & kubectl delete secret $args }
function ksysrmsec() { & kubectl --namespace=kube-system delete secret $args }
function kgno() { & kubectl get nodes $args }
function kdno() { & kubectl describe nodes $args }
function kgns() { & kubectl get namespaces $args }
function kdns() { & kubectl describe namespaces $args }
function krmns() { & kubectl delete namespaces $args }
function kgoyaml() { & kubectl get -o=yaml $args }
function ksysgoyaml() { & kubectl --namespace=kube-system get -o=yaml $args }
function kgpooyaml() { & kubectl get pods -o=yaml $args }
function ksysgpooyaml() { & kubectl --namespace=kube-system get pods -o=yaml $args }
function kgdepoyaml() { & kubectl get deployment -o=yaml $args }
function ksysgdepoyaml() { & kubectl --namespace=kube-system get deployment -o=yaml $args }
function kgsvcoyaml() { & kubectl get service -o=yaml $args }
function ksysgsvcoyaml() { & kubectl --namespace=kube-system get service -o=yaml $args }
function kgingoyaml() { & kubectl get ingress -o=yaml $args }
function ksysgingoyaml() { & kubectl --namespace=kube-system get ingress -o=yaml $args }
function kgcmoyaml() { & kubectl get configmap -o=yaml $args }
function ksysgcmoyaml() { & kubectl --namespace=kube-system get configmap -o=yaml $args }
function kgsecoyaml() { & kubectl get secret -o=yaml $args }
function ksysgsecoyaml() { & kubectl --namespace=kube-system get secret -o=yaml $args }
function kgnooyaml() { & kubectl get nodes -o=yaml $args }
function kgnsoyaml() { & kubectl get namespaces -o=yaml $args }
function kgowide() { & kubectl get -o=wide $args }
function ksysgowide() { & kubectl --namespace=kube-system get -o=wide $args }
function kgpoowide() { & kubectl get pods -o=wide $args }
function ksysgpoowide() { & kubectl --namespace=kube-system get pods -o=wide $args }
function kgdepowide() { & kubectl get deployment -o=wide $args }
function ksysgdepowide() { & kubectl --namespace=kube-system get deployment -o=wide $args }
function kgsvcowide() { & kubectl get service -o=wide $args }
function ksysgsvcowide() { & kubectl --namespace=kube-system get service -o=wide $args }
function kgingowide() { & kubectl get ingress -o=wide $args }
function ksysgingowide() { & kubectl --namespace=kube-system get ingress -o=wide $args }
function kgcmowide() { & kubectl get configmap -o=wide $args }
function ksysgcmowide() { & kubectl --namespace=kube-system get configmap -o=wide $args }
function kgsecowide() { & kubectl get secret -o=wide $args }
function ksysgsecowide() { & kubectl --namespace=kube-system get secret -o=wide $args }
function kgnoowide() { & kubectl get nodes -o=wide $args }
function kgnsowide() { & kubectl get namespaces -o=wide $args }
function kgojson() { & kubectl get -o=json $args }
function ksysgojson() { & kubectl --namespace=kube-system get -o=json $args }
function kgpoojson() { & kubectl get pods -o=json $args }
function ksysgpoojson() { & kubectl --namespace=kube-system get pods -o=json $args }
function kgdepojson() { & kubectl get deployment -o=json $args }
function ksysgdepojson() { & kubectl --namespace=kube-system get deployment -o=json $args }
function kgsvcojson() { & kubectl get service -o=json $args }
function ksysgsvcojson() { & kubectl --namespace=kube-system get service -o=json $args }
function kgingojson() { & kubectl get ingress -o=json $args }
function ksysgingojson() { & kubectl --namespace=kube-system get ingress -o=json $args }
function kgcmojson() { & kubectl get configmap -o=json $args }
function ksysgcmojson() { & kubectl --namespace=kube-system get configmap -o=json $args }
function kgsecojson() { & kubectl get secret -o=json $args }
function ksysgsecojson() { & kubectl --namespace=kube-system get secret -o=json $args }
function kgnoojson() { & kubectl get nodes -o=json $args }
function kgnsojson() { & kubectl get namespaces -o=json $args }
function kgall() { & kubectl get --all-namespaces $args }
function kdall() { & kubectl describe --all-namespaces $args }
function kgpoall() { & kubectl get pods --all-namespaces $args }
function kdpoall() { & kubectl describe pods --all-namespaces $args }
function kgdepall() { & kubectl get deployment --all-namespaces $args }
function kddepall() { & kubectl describe deployment --all-namespaces $args }
function kgsvcall() { & kubectl get service --all-namespaces $args }
function kdsvcall() { & kubectl describe service --all-namespaces $args }
function kgingall() { & kubectl get ingress --all-namespaces $args }
function kdingall() { & kubectl describe ingress --all-namespaces $args }
function kgcmall() { & kubectl get configmap --all-namespaces $args }
function kdcmall() { & kubectl describe configmap --all-namespaces $args }
function kgsecall() { & kubectl get secret --all-namespaces $args }
function kdsecall() { & kubectl describe secret --all-namespaces $args }
function kgnsall() { & kubectl get namespaces --all-namespaces $args }
function kdnsall() { & kubectl describe namespaces --all-namespaces $args }
function kgsl() { & kubectl get --show-labels $args }
function ksysgsl() { & kubectl --namespace=kube-system get --show-labels $args }
function kgposl() { & kubectl get pods --show-labels $args }
function ksysgposl() { & kubectl --namespace=kube-system get pods --show-labels $args }
function kgdepsl() { & kubectl get deployment --show-labels $args }
function ksysgdepsl() { & kubectl --namespace=kube-system get deployment --show-labels $args }
function krmall() { & kubectl delete --all $args }
function ksysrmall() { & kubectl --namespace=kube-system delete --all $args }
function krmpoall() { & kubectl delete pods --all $args }
function ksysrmpoall() { & kubectl --namespace=kube-system delete pods --all $args }
function krmdepall() { & kubectl delete deployment --all $args }
function ksysrmdepall() { & kubectl --namespace=kube-system delete deployment --all $args }
function krmsvcall() { & kubectl delete service --all $args }
function ksysrmsvcall() { & kubectl --namespace=kube-system delete service --all $args }
function krmingall() { & kubectl delete ingress --all $args }
function ksysrmingall() { & kubectl --namespace=kube-system delete ingress --all $args }
function krmcmall() { & kubectl delete configmap --all $args }
function ksysrmcmall() { & kubectl --namespace=kube-system delete configmap --all $args }
function krmsecall() { & kubectl delete secret --all $args }
function ksysrmsecall() { & kubectl --namespace=kube-system delete secret --all $args }
function krmnsall() { & kubectl delete namespaces --all $args }
function kgw() { & kubectl get --watch $args }
function ksysgw() { & kubectl --namespace=kube-system get --watch $args }
function kgpow() { & kubectl get pods --watch $args }
function ksysgpow() { & kubectl --namespace=kube-system get pods --watch $args }
function kgdepw() { & kubectl get deployment --watch $args }
function ksysgdepw() { & kubectl --namespace=kube-system get deployment --watch $args }
function kgsvcw() { & kubectl get service --watch $args }
function ksysgsvcw() { & kubectl --namespace=kube-system get service --watch $args }
function kgingw() { & kubectl get ingress --watch $args }
function ksysgingw() { & kubectl --namespace=kube-system get ingress --watch $args }
function kgcmw() { & kubectl get configmap --watch $args }
function ksysgcmw() { & kubectl --namespace=kube-system get configmap --watch $args }
function kgsecw() { & kubectl get secret --watch $args }
function ksysgsecw() { & kubectl --namespace=kube-system get secret --watch $args }
function kgnow() { & kubectl get nodes --watch $args }
function kgnsw() { & kubectl get namespaces --watch $args }
function kgoyamlall() { & kubectl get -o=yaml --all-namespaces $args }
function kgpooyamlall() { & kubectl get pods -o=yaml --all-namespaces $args }
function kgdepoyamlall() { & kubectl get deployment -o=yaml --all-namespaces $args }
function kgsvcoyamlall() { & kubectl get service -o=yaml --all-namespaces $args }
function kgingoyamlall() { & kubectl get ingress -o=yaml --all-namespaces $args }
function kgcmoyamlall() { & kubectl get configmap -o=yaml --all-namespaces $args }
function kgsecoyamlall() { & kubectl get secret -o=yaml --all-namespaces $args }
function kgnsoyamlall() { & kubectl get namespaces -o=yaml --all-namespaces $args }
function kgalloyaml() { & kubectl get --all-namespaces -o=yaml $args }
function kgpoalloyaml() { & kubectl get pods --all-namespaces -o=yaml $args }
function kgdepalloyaml() { & kubectl get deployment --all-namespaces -o=yaml $args }
function kgsvcalloyaml() { & kubectl get service --all-namespaces -o=yaml $args }
function kgingalloyaml() { & kubectl get ingress --all-namespaces -o=yaml $args }
function kgcmalloyaml() { & kubectl get configmap --all-namespaces -o=yaml $args }
function kgsecalloyaml() { & kubectl get secret --all-namespaces -o=yaml $args }
function kgnsalloyaml() { & kubectl get namespaces --all-namespaces -o=yaml $args }
function kgwoyaml() { & kubectl get --watch -o=yaml $args }
function ksysgwoyaml() { & kubectl --namespace=kube-system get --watch -o=yaml $args }
function kgpowoyaml() { & kubectl get pods --watch -o=yaml $args }
function ksysgpowoyaml() { & kubectl --namespace=kube-system get pods --watch -o=yaml $args }
function kgdepwoyaml() { & kubectl get deployment --watch -o=yaml $args }
function ksysgdepwoyaml() { & kubectl --namespace=kube-system get deployment --watch -o=yaml $args }
function kgsvcwoyaml() { & kubectl get service --watch -o=yaml $args }
function ksysgsvcwoyaml() { & kubectl --namespace=kube-system get service --watch -o=yaml $args }
function kgingwoyaml() { & kubectl get ingress --watch -o=yaml $args }
function ksysgingwoyaml() { & kubectl --namespace=kube-system get ingress --watch -o=yaml $args }
function kgcmwoyaml() { & kubectl get configmap --watch -o=yaml $args }
function ksysgcmwoyaml() { & kubectl --namespace=kube-system get configmap --watch -o=yaml $args }
function kgsecwoyaml() { & kubectl get secret --watch -o=yaml $args }
function ksysgsecwoyaml() { & kubectl --namespace=kube-system get secret --watch -o=yaml $args }
function kgnowoyaml() { & kubectl get nodes --watch -o=yaml $args }
function kgnswoyaml() { & kubectl get namespaces --watch -o=yaml $args }
function kgowideall() { & kubectl get -o=wide --all-namespaces $args }
function kgpoowideall() { & kubectl get pods -o=wide --all-namespaces $args }
function kgdepowideall() { & kubectl get deployment -o=wide --all-namespaces $args }
function kgsvcowideall() { & kubectl get service -o=wide --all-namespaces $args }
function kgingowideall() { & kubectl get ingress -o=wide --all-namespaces $args }
function kgcmowideall() { & kubectl get configmap -o=wide --all-namespaces $args }
function kgsecowideall() { & kubectl get secret -o=wide --all-namespaces $args }
function kgnsowideall() { & kubectl get namespaces -o=wide --all-namespaces $args }
function kgallowide() { & kubectl get --all-namespaces -o=wide $args }
function kgpoallowide() { & kubectl get pods --all-namespaces -o=wide $args }
function kgdepallowide() { & kubectl get deployment --all-namespaces -o=wide $args }
function kgsvcallowide() { & kubectl get service --all-namespaces -o=wide $args }
function kgingallowide() { & kubectl get ingress --all-namespaces -o=wide $args }
function kgcmallowide() { & kubectl get configmap --all-namespaces -o=wide $args }
function kgsecallowide() { & kubectl get secret --all-namespaces -o=wide $args }
function kgnsallowide() { & kubectl get namespaces --all-namespaces -o=wide $args }
function kgowidesl() { & kubectl get -o=wide --show-labels $args }
function ksysgowidesl() { & kubectl --namespace=kube-system get -o=wide --show-labels $args }
function kgpoowidesl() { & kubectl get pods -o=wide --show-labels $args }
function ksysgpoowidesl() { & kubectl --namespace=kube-system get pods -o=wide --show-labels $args }
function kgdepowidesl() { & kubectl get deployment -o=wide --show-labels $args }
function ksysgdepowidesl() { & kubectl --namespace=kube-system get deployment -o=wide --show-labels $args }
function kgslowide() { & kubectl get --show-labels -o=wide $args }
function ksysgslowide() { & kubectl --namespace=kube-system get --show-labels -o=wide $args }
function kgposlowide() { & kubectl get pods --show-labels -o=wide $args }
function ksysgposlowide() { & kubectl --namespace=kube-system get pods --show-labels -o=wide $args }
function kgdepslowide() { & kubectl get deployment --show-labels -o=wide $args }
function ksysgdepslowide() { & kubectl --namespace=kube-system get deployment --show-labels -o=wide $args }
function kgwowide() { & kubectl get --watch -o=wide $args }
function ksysgwowide() { & kubectl --namespace=kube-system get --watch -o=wide $args }
function kgpowowide() { & kubectl get pods --watch -o=wide $args }
function ksysgpowowide() { & kubectl --namespace=kube-system get pods --watch -o=wide $args }
function kgdepwowide() { & kubectl get deployment --watch -o=wide $args }
function ksysgdepwowide() { & kubectl --namespace=kube-system get deployment --watch -o=wide $args }
function kgsvcwowide() { & kubectl get service --watch -o=wide $args }
function ksysgsvcwowide() { & kubectl --namespace=kube-system get service --watch -o=wide $args }
function kgingwowide() { & kubectl get ingress --watch -o=wide $args }
function ksysgingwowide() { & kubectl --namespace=kube-system get ingress --watch -o=wide $args }
function kgcmwowide() { & kubectl get configmap --watch -o=wide $args }
function ksysgcmwowide() { & kubectl --namespace=kube-system get configmap --watch -o=wide $args }
function kgsecwowide() { & kubectl get secret --watch -o=wide $args }
function ksysgsecwowide() { & kubectl --namespace=kube-system get secret --watch -o=wide $args }
function kgnowowide() { & kubectl get nodes --watch -o=wide $args }
function kgnswowide() { & kubectl get namespaces --watch -o=wide $args }
function kgojsonall() { & kubectl get -o=json --all-namespaces $args }
function kgpoojsonall() { & kubectl get pods -o=json --all-namespaces $args }
function kgdepojsonall() { & kubectl get deployment -o=json --all-namespaces $args }
function kgsvcojsonall() { & kubectl get service -o=json --all-namespaces $args }
function kgingojsonall() { & kubectl get ingress -o=json --all-namespaces $args }
function kgcmojsonall() { & kubectl get configmap -o=json --all-namespaces $args }
function kgsecojsonall() { & kubectl get secret -o=json --all-namespaces $args }
function kgnsojsonall() { & kubectl get namespaces -o=json --all-namespaces $args }
function kgallojson() { & kubectl get --all-namespaces -o=json $args }
function kgpoallojson() { & kubectl get pods --all-namespaces -o=json $args }
function kgdepallojson() { & kubectl get deployment --all-namespaces -o=json $args }
function kgsvcallojson() { & kubectl get service --all-namespaces -o=json $args }
function kgingallojson() { & kubectl get ingress --all-namespaces -o=json $args }
function kgcmallojson() { & kubectl get configmap --all-namespaces -o=json $args }
function kgsecallojson() { & kubectl get secret --all-namespaces -o=json $args }
function kgnsallojson() { & kubectl get namespaces --all-namespaces -o=json $args }
function kgwojson() { & kubectl get --watch -o=json $args }
function ksysgwojson() { & kubectl --namespace=kube-system get --watch -o=json $args }
function kgpowojson() { & kubectl get pods --watch -o=json $args }
function ksysgpowojson() { & kubectl --namespace=kube-system get pods --watch -o=json $args }
function kgdepwojson() { & kubectl get deployment --watch -o=json $args }
function ksysgdepwojson() { & kubectl --namespace=kube-system get deployment --watch -o=json $args }
function kgsvcwojson() { & kubectl get service --watch -o=json $args }
function ksysgsvcwojson() { & kubectl --namespace=kube-system get service --watch -o=json $args }
function kgingwojson() { & kubectl get ingress --watch -o=json $args }
function ksysgingwojson() { & kubectl --namespace=kube-system get ingress --watch -o=json $args }
function kgcmwojson() { & kubectl get configmap --watch -o=json $args }
function ksysgcmwojson() { & kubectl --namespace=kube-system get configmap --watch -o=json $args }
function kgsecwojson() { & kubectl get secret --watch -o=json $args }
function ksysgsecwojson() { & kubectl --namespace=kube-system get secret --watch -o=json $args }
function kgnowojson() { & kubectl get nodes --watch -o=json $args }
function kgnswojson() { & kubectl get namespaces --watch -o=json $args }
function kgallsl() { & kubectl get --all-namespaces --show-labels $args }
function kgpoallsl() { & kubectl get pods --all-namespaces --show-labels $args }
function kgdepallsl() { & kubectl get deployment --all-namespaces --show-labels $args }
function kgslall() { & kubectl get --show-labels --all-namespaces $args }
function kgposlall() { & kubectl get pods --show-labels --all-namespaces $args }
function kgdepslall() { & kubectl get deployment --show-labels --all-namespaces $args }
function kgallw() { & kubectl get --all-namespaces --watch $args }
function kgpoallw() { & kubectl get pods --all-namespaces --watch $args }
function kgdepallw() { & kubectl get deployment --all-namespaces --watch $args }
function kgsvcallw() { & kubectl get service --all-namespaces --watch $args }
function kgingallw() { & kubectl get ingress --all-namespaces --watch $args }
function kgcmallw() { & kubectl get configmap --all-namespaces --watch $args }
function kgsecallw() { & kubectl get secret --all-namespaces --watch $args }
function kgnsallw() { & kubectl get namespaces --all-namespaces --watch $args }
function kgwall() { & kubectl get --watch --all-namespaces $args }
function kgpowall() { & kubectl get pods --watch --all-namespaces $args }
function kgdepwall() { & kubectl get deployment --watch --all-namespaces $args }
function kgsvcwall() { & kubectl get service --watch --all-namespaces $args }
function kgingwall() { & kubectl get ingress --watch --all-namespaces $args }
function kgcmwall() { & kubectl get configmap --watch --all-namespaces $args }
function kgsecwall() { & kubectl get secret --watch --all-namespaces $args }
function kgnswall() { & kubectl get namespaces --watch --all-namespaces $args }
function kgslw() { & kubectl get --show-labels --watch $args }
function ksysgslw() { & kubectl --namespace=kube-system get --show-labels --watch $args }
function kgposlw() { & kubectl get pods --show-labels --watch $args }
function ksysgposlw() { & kubectl --namespace=kube-system get pods --show-labels --watch $args }
function kgdepslw() { & kubectl get deployment --show-labels --watch $args }
function ksysgdepslw() { & kubectl --namespace=kube-system get deployment --show-labels --watch $args }
function kgwsl() { & kubectl get --watch --show-labels $args }
function ksysgwsl() { & kubectl --namespace=kube-system get --watch --show-labels $args }
function kgpowsl() { & kubectl get pods --watch --show-labels $args }
function ksysgpowsl() { & kubectl --namespace=kube-system get pods --watch --show-labels $args }
function kgdepwsl() { & kubectl get deployment --watch --show-labels $args }
function ksysgdepwsl() { & kubectl --namespace=kube-system get deployment --watch --show-labels $args }
function kgallwoyaml() { & kubectl get --all-namespaces --watch -o=yaml $args }
function kgpoallwoyaml() { & kubectl get pods --all-namespaces --watch -o=yaml $args }
function kgdepallwoyaml() { & kubectl get deployment --all-namespaces --watch -o=yaml $args }
function kgsvcallwoyaml() { & kubectl get service --all-namespaces --watch -o=yaml $args }
function kgingallwoyaml() { & kubectl get ingress --all-namespaces --watch -o=yaml $args }
function kgcmallwoyaml() { & kubectl get configmap --all-namespaces --watch -o=yaml $args }
function kgsecallwoyaml() { & kubectl get secret --all-namespaces --watch -o=yaml $args }
function kgnsallwoyaml() { & kubectl get namespaces --all-namespaces --watch -o=yaml $args }
function kgwoyamlall() { & kubectl get --watch -o=yaml --all-namespaces $args }
function kgpowoyamlall() { & kubectl get pods --watch -o=yaml --all-namespaces $args }
function kgdepwoyamlall() { & kubectl get deployment --watch -o=yaml --all-namespaces $args }
function kgsvcwoyamlall() { & kubectl get service --watch -o=yaml --all-namespaces $args }
function kgingwoyamlall() { & kubectl get ingress --watch -o=yaml --all-namespaces $args }
function kgcmwoyamlall() { & kubectl get configmap --watch -o=yaml --all-namespaces $args }
function kgsecwoyamlall() { & kubectl get secret --watch -o=yaml --all-namespaces $args }
function kgnswoyamlall() { & kubectl get namespaces --watch -o=yaml --all-namespaces $args }
function kgwalloyaml() { & kubectl get --watch --all-namespaces -o=yaml $args }
function kgpowalloyaml() { & kubectl get pods --watch --all-namespaces -o=yaml $args }
function kgdepwalloyaml() { & kubectl get deployment --watch --all-namespaces -o=yaml $args }
function kgsvcwalloyaml() { & kubectl get service --watch --all-namespaces -o=yaml $args }
function kgingwalloyaml() { & kubectl get ingress --watch --all-namespaces -o=yaml $args }
function kgcmwalloyaml() { & kubectl get configmap --watch --all-namespaces -o=yaml $args }
function kgsecwalloyaml() { & kubectl get secret --watch --all-namespaces -o=yaml $args }
function kgnswalloyaml() { & kubectl get namespaces --watch --all-namespaces -o=yaml $args }
function kgowideallsl() { & kubectl get -o=wide --all-namespaces --show-labels $args }
function kgpoowideallsl() { & kubectl get pods -o=wide --all-namespaces --show-labels $args }
function kgdepowideallsl() { & kubectl get deployment -o=wide --all-namespaces --show-labels $args }
function kgowideslall() { & kubectl get -o=wide --show-labels --all-namespaces $args }
function kgpoowideslall() { & kubectl get pods -o=wide --show-labels --all-namespaces $args }
function kgdepowideslall() { & kubectl get deployment -o=wide --show-labels --all-namespaces $args }
function kgallowidesl() { & kubectl get --all-namespaces -o=wide --show-labels $args }
function kgpoallowidesl() { & kubectl get pods --all-namespaces -o=wide --show-labels $args }
function kgdepallowidesl() { & kubectl get deployment --all-namespaces -o=wide --show-labels $args }
function kgallslowide() { & kubectl get --all-namespaces --show-labels -o=wide $args }
function kgpoallslowide() { & kubectl get pods --all-namespaces --show-labels -o=wide $args }
function kgdepallslowide() { & kubectl get deployment --all-namespaces --show-labels -o=wide $args }
function kgslowideall() { & kubectl get --show-labels -o=wide --all-namespaces $args }
function kgposlowideall() { & kubectl get pods --show-labels -o=wide --all-namespaces $args }
function kgdepslowideall() { & kubectl get deployment --show-labels -o=wide --all-namespaces $args }
function kgslallowide() { & kubectl get --show-labels --all-namespaces -o=wide $args }
function kgposlallowide() { & kubectl get pods --show-labels --all-namespaces -o=wide $args }
function kgdepslallowide() { & kubectl get deployment --show-labels --all-namespaces -o=wide $args }
function kgallwowide() { & kubectl get --all-namespaces --watch -o=wide $args }
function kgpoallwowide() { & kubectl get pods --all-namespaces --watch -o=wide $args }
function kgdepallwowide() { & kubectl get deployment --all-namespaces --watch -o=wide $args }
function kgsvcallwowide() { & kubectl get service --all-namespaces --watch -o=wide $args }
function kgingallwowide() { & kubectl get ingress --all-namespaces --watch -o=wide $args }
function kgcmallwowide() { & kubectl get configmap --all-namespaces --watch -o=wide $args }
function kgsecallwowide() { & kubectl get secret --all-namespaces --watch -o=wide $args }
function kgnsallwowide() { & kubectl get namespaces --all-namespaces --watch -o=wide $args }
function kgwowideall() { & kubectl get --watch -o=wide --all-namespaces $args }
function kgpowowideall() { & kubectl get pods --watch -o=wide --all-namespaces $args }
function kgdepwowideall() { & kubectl get deployment --watch -o=wide --all-namespaces $args }
function kgsvcwowideall() { & kubectl get service --watch -o=wide --all-namespaces $args }
function kgingwowideall() { & kubectl get ingress --watch -o=wide --all-namespaces $args }
function kgcmwowideall() { & kubectl get configmap --watch -o=wide --all-namespaces $args }
function kgsecwowideall() { & kubectl get secret --watch -o=wide --all-namespaces $args }
function kgnswowideall() { & kubectl get namespaces --watch -o=wide --all-namespaces $args }
function kgwallowide() { & kubectl get --watch --all-namespaces -o=wide $args }
function kgpowallowide() { & kubectl get pods --watch --all-namespaces -o=wide $args }
function kgdepwallowide() { & kubectl get deployment --watch --all-namespaces -o=wide $args }
function kgsvcwallowide() { & kubectl get service --watch --all-namespaces -o=wide $args }
function kgingwallowide() { & kubectl get ingress --watch --all-namespaces -o=wide $args }
function kgcmwallowide() { & kubectl get configmap --watch --all-namespaces -o=wide $args }
function kgsecwallowide() { & kubectl get secret --watch --all-namespaces -o=wide $args }
function kgnswallowide() { & kubectl get namespaces --watch --all-namespaces -o=wide $args }
function kgslwowide() { & kubectl get --show-labels --watch -o=wide $args }
function ksysgslwowide() { & kubectl --namespace=kube-system get --show-labels --watch -o=wide $args }
function kgposlwowide() { & kubectl get pods --show-labels --watch -o=wide $args }
function ksysgposlwowide() { & kubectl --namespace=kube-system get pods --show-labels --watch -o=wide $args }
function kgdepslwowide() { & kubectl get deployment --show-labels --watch -o=wide $args }
function ksysgdepslwowide() { & kubectl --namespace=kube-system get deployment --show-labels --watch -o=wide $args }
function kgwowidesl() { & kubectl get --watch -o=wide --show-labels $args }
function ksysgwowidesl() { & kubectl --namespace=kube-system get --watch -o=wide --show-labels $args }
function kgpowowidesl() { & kubectl get pods --watch -o=wide --show-labels $args }
function ksysgpowowidesl() { & kubectl --namespace=kube-system get pods --watch -o=wide --show-labels $args }
function kgdepwowidesl() { & kubectl get deployment --watch -o=wide --show-labels $args }
function ksysgdepwowidesl() { & kubectl --namespace=kube-system get deployment --watch -o=wide --show-labels $args }
function kgwslowide() { & kubectl get --watch --show-labels -o=wide $args }
function ksysgwslowide() { & kubectl --namespace=kube-system get --watch --show-labels -o=wide $args }
function kgpowslowide() { & kubectl get pods --watch --show-labels -o=wide $args }
function ksysgpowslowide() { & kubectl --namespace=kube-system get pods --watch --show-labels -o=wide $args }
function kgdepwslowide() { & kubectl get deployment --watch --show-labels -o=wide $args }
function ksysgdepwslowide() { & kubectl --namespace=kube-system get deployment --watch --show-labels -o=wide $args }
function kgallwojson() { & kubectl get --all-namespaces --watch -o=json $args }
function kgpoallwojson() { & kubectl get pods --all-namespaces --watch -o=json $args }
function kgdepallwojson() { & kubectl get deployment --all-namespaces --watch -o=json $args }
function kgsvcallwojson() { & kubectl get service --all-namespaces --watch -o=json $args }
function kgingallwojson() { & kubectl get ingress --all-namespaces --watch -o=json $args }
function kgcmallwojson() { & kubectl get configmap --all-namespaces --watch -o=json $args }
function kgsecallwojson() { & kubectl get secret --all-namespaces --watch -o=json $args }
function kgnsallwojson() { & kubectl get namespaces --all-namespaces --watch -o=json $args }
function kgwojsonall() { & kubectl get --watch -o=json --all-namespaces $args }
function kgpowojsonall() { & kubectl get pods --watch -o=json --all-namespaces $args }
function kgdepwojsonall() { & kubectl get deployment --watch -o=json --all-namespaces $args }
function kgsvcwojsonall() { & kubectl get service --watch -o=json --all-namespaces $args }
function kgingwojsonall() { & kubectl get ingress --watch -o=json --all-namespaces $args }
function kgcmwojsonall() { & kubectl get configmap --watch -o=json --all-namespaces $args }
function kgsecwojsonall() { & kubectl get secret --watch -o=json --all-namespaces $args }
function kgnswojsonall() { & kubectl get namespaces --watch -o=json --all-namespaces $args }
function kgwallojson() { & kubectl get --watch --all-namespaces -o=json $args }
function kgpowallojson() { & kubectl get pods --watch --all-namespaces -o=json $args }
function kgdepwallojson() { & kubectl get deployment --watch --all-namespaces -o=json $args }
function kgsvcwallojson() { & kubectl get service --watch --all-namespaces -o=json $args }
function kgingwallojson() { & kubectl get ingress --watch --all-namespaces -o=json $args }
function kgcmwallojson() { & kubectl get configmap --watch --all-namespaces -o=json $args }
function kgsecwallojson() { & kubectl get secret --watch --all-namespaces -o=json $args }
function kgnswallojson() { & kubectl get namespaces --watch --all-namespaces -o=json $args }
function kgallslw() { & kubectl get --all-namespaces --show-labels --watch $args }
function kgpoallslw() { & kubectl get pods --all-namespaces --show-labels --watch $args }
function kgdepallslw() { & kubectl get deployment --all-namespaces --show-labels --watch $args }
function kgallwsl() { & kubectl get --all-namespaces --watch --show-labels $args }
function kgpoallwsl() { & kubectl get pods --all-namespaces --watch --show-labels $args }
function kgdepallwsl() { & kubectl get deployment --all-namespaces --watch --show-labels $args }
function kgslallw() { & kubectl get --show-labels --all-namespaces --watch $args }
function kgposlallw() { & kubectl get pods --show-labels --all-namespaces --watch $args }
function kgdepslallw() { & kubectl get deployment --show-labels --all-namespaces --watch $args }
function kgslwall() { & kubectl get --show-labels --watch --all-namespaces $args }
function kgposlwall() { & kubectl get pods --show-labels --watch --all-namespaces $args }
function kgdepslwall() { & kubectl get deployment --show-labels --watch --all-namespaces $args }
function kgwallsl() { & kubectl get --watch --all-namespaces --show-labels $args }
function kgpowallsl() { & kubectl get pods --watch --all-namespaces --show-labels $args }
function kgdepwallsl() { & kubectl get deployment --watch --all-namespaces --show-labels $args }
function kgwslall() { & kubectl get --watch --show-labels --all-namespaces $args }
function kgpowslall() { & kubectl get pods --watch --show-labels --all-namespaces $args }
function kgdepwslall() { & kubectl get deployment --watch --show-labels --all-namespaces $args }
function kgallslwowide() { & kubectl get --all-namespaces --show-labels --watch -o=wide $args }
function kgpoallslwowide() { & kubectl get pods --all-namespaces --show-labels --watch -o=wide $args }
function kgdepallslwowide() { & kubectl get deployment --all-namespaces --show-labels --watch -o=wide $args }
function kgallwowidesl() { & kubectl get --all-namespaces --watch -o=wide --show-labels $args }
function kgpoallwowidesl() { & kubectl get pods --all-namespaces --watch -o=wide --show-labels $args }
function kgdepallwowidesl() { & kubectl get deployment --all-namespaces --watch -o=wide --show-labels $args }
function kgallwslowide() { & kubectl get --all-namespaces --watch --show-labels -o=wide $args }
function kgpoallwslowide() { & kubectl get pods --all-namespaces --watch --show-labels -o=wide $args }
function kgdepallwslowide() { & kubectl get deployment --all-namespaces --watch --show-labels -o=wide $args }
function kgslallwowide() { & kubectl get --show-labels --all-namespaces --watch -o=wide $args }
function kgposlallwowide() { & kubectl get pods --show-labels --all-namespaces --watch -o=wide $args }
function kgdepslallwowide() { & kubectl get deployment --show-labels --all-namespaces --watch -o=wide $args }
function kgslwowideall() { & kubectl get --show-labels --watch -o=wide --all-namespaces $args }
function kgposlwowideall() { & kubectl get pods --show-labels --watch -o=wide --all-namespaces $args }
function kgdepslwowideall() { & kubectl get deployment --show-labels --watch -o=wide --all-namespaces $args }
function kgslwallowide() { & kubectl get --show-labels --watch --all-namespaces -o=wide $args }
function kgposlwallowide() { & kubectl get pods --show-labels --watch --all-namespaces -o=wide $args }
function kgdepslwallowide() { & kubectl get deployment --show-labels --watch --all-namespaces -o=wide $args }
function kgwowideallsl() { & kubectl get --watch -o=wide --all-namespaces --show-labels $args }
function kgpowowideallsl() { & kubectl get pods --watch -o=wide --all-namespaces --show-labels $args }
function kgdepwowideallsl() { & kubectl get deployment --watch -o=wide --all-namespaces --show-labels $args }
function kgwowideslall() { & kubectl get --watch -o=wide --show-labels --all-namespaces $args }
function kgpowowideslall() { & kubectl get pods --watch -o=wide --show-labels --all-namespaces $args }
function kgdepwowideslall() { & kubectl get deployment --watch -o=wide --show-labels --all-namespaces $args }
function kgwallowidesl() { & kubectl get --watch --all-namespaces -o=wide --show-labels $args }
function kgpowallowidesl() { & kubectl get pods --watch --all-namespaces -o=wide --show-labels $args }
function kgdepwallowidesl() { & kubectl get deployment --watch --all-namespaces -o=wide --show-labels $args }
function kgwallslowide() { & kubectl get --watch --all-namespaces --show-labels -o=wide $args }
function kgpowallslowide() { & kubectl get pods --watch --all-namespaces --show-labels -o=wide $args }
function kgdepwallslowide() { & kubectl get deployment --watch --all-namespaces --show-labels -o=wide $args }
function kgwslowideall() { & kubectl get --watch --show-labels -o=wide --all-namespaces $args }
function kgpowslowideall() { & kubectl get pods --watch --show-labels -o=wide --all-namespaces $args }
function kgdepwslowideall() { & kubectl get deployment --watch --show-labels -o=wide --all-namespaces $args }
function kgwslallowide() { & kubectl get --watch --show-labels --all-namespaces -o=wide $args }
function kgpowslallowide() { & kubectl get pods --watch --show-labels --all-namespaces -o=wide $args }
function kgdepwslallowide() { & kubectl get deployment --watch --show-labels --all-namespaces -o=wide $args }
function kgf() { & kubectl get --recursive -f $args }
function kdf() { & kubectl describe --recursive -f $args }
function krmf() { & kubectl delete --recursive -f $args }
function kgoyamlf() { & kubectl get -o=yaml --recursive -f $args }
function kgowidef() { & kubectl get -o=wide --recursive -f $args }
function kgojsonf() { & kubectl get -o=json --recursive -f $args }
function kgslf() { & kubectl get --show-labels --recursive -f $args }
function kgwf() { & kubectl get --watch --recursive -f $args }
function kgwoyamlf() { & kubectl get --watch -o=yaml --recursive -f $args }
function kgowideslf() { & kubectl get -o=wide --show-labels --recursive -f $args }
function kgslowidef() { & kubectl get --show-labels -o=wide --recursive -f $args }
function kgwowidef() { & kubectl get --watch -o=wide --recursive -f $args }
function kgwojsonf() { & kubectl get --watch -o=json --recursive -f $args }
function kgslwf() { & kubectl get --show-labels --watch --recursive -f $args }
function kgwslf() { & kubectl get --watch --show-labels --recursive -f $args }
function kgslwowidef() { & kubectl get --show-labels --watch -o=wide --recursive -f $args }
function kgwowideslf() { & kubectl get --watch -o=wide --show-labels --recursive -f $args }
function kgwslowidef() { & kubectl get --watch --show-labels -o=wide --recursive -f $args }
function kgl() { & kubectl get -l $args }
function ksysgl() { & kubectl --namespace=kube-system get -l $args }
function kdl() { & kubectl describe -l $args }
function ksysdl() { & kubectl --namespace=kube-system describe -l $args }
function krml() { & kubectl delete -l $args }
function ksysrml() { & kubectl --namespace=kube-system delete -l $args }
function kgpol() { & kubectl get pods -l $args }
function ksysgpol() { & kubectl --namespace=kube-system get pods -l $args }
function kdpol() { & kubectl describe pods -l $args }
function ksysdpol() { & kubectl --namespace=kube-system describe pods -l $args }
function krmpol() { & kubectl delete pods -l $args }
function ksysrmpol() { & kubectl --namespace=kube-system delete pods -l $args }
function kgdepl() { & kubectl get deployment -l $args }
function ksysgdepl() { & kubectl --namespace=kube-system get deployment -l $args }
function kddepl() { & kubectl describe deployment -l $args }
function ksysddepl() { & kubectl --namespace=kube-system describe deployment -l $args }
function krmdepl() { & kubectl delete deployment -l $args }
function ksysrmdepl() { & kubectl --namespace=kube-system delete deployment -l $args }
function kgsvcl() { & kubectl get service -l $args }
function ksysgsvcl() { & kubectl --namespace=kube-system get service -l $args }
function kdsvcl() { & kubectl describe service -l $args }
function ksysdsvcl() { & kubectl --namespace=kube-system describe service -l $args }
function krmsvcl() { & kubectl delete service -l $args }
function ksysrmsvcl() { & kubectl --namespace=kube-system delete service -l $args }
function kgingl() { & kubectl get ingress -l $args }
function ksysgingl() { & kubectl --namespace=kube-system get ingress -l $args }
function kdingl() { & kubectl describe ingress -l $args }
function ksysdingl() { & kubectl --namespace=kube-system describe ingress -l $args }
function krmingl() { & kubectl delete ingress -l $args }
function ksysrmingl() { & kubectl --namespace=kube-system delete ingress -l $args }
function kgcml() { & kubectl get configmap -l $args }
function ksysgcml() { & kubectl --namespace=kube-system get configmap -l $args }
function kdcml() { & kubectl describe configmap -l $args }
function ksysdcml() { & kubectl --namespace=kube-system describe configmap -l $args }
function krmcml() { & kubectl delete configmap -l $args }
function ksysrmcml() { & kubectl --namespace=kube-system delete configmap -l $args }
function kgsecl() { & kubectl get secret -l $args }
function ksysgsecl() { & kubectl --namespace=kube-system get secret -l $args }
function kdsecl() { & kubectl describe secret -l $args }
function ksysdsecl() { & kubectl --namespace=kube-system describe secret -l $args }
function krmsecl() { & kubectl delete secret -l $args }
function ksysrmsecl() { & kubectl --namespace=kube-system delete secret -l $args }
function kgnol() { & kubectl get nodes -l $args }
function kdnol() { & kubectl describe nodes -l $args }
function kgnsl() { & kubectl get namespaces -l $args }
function kdnsl() { & kubectl describe namespaces -l $args }
function krmnsl() { & kubectl delete namespaces -l $args }
function kgoyamll() { & kubectl get -o=yaml -l $args }
function ksysgoyamll() { & kubectl --namespace=kube-system get -o=yaml -l $args }
function kgpooyamll() { & kubectl get pods -o=yaml -l $args }
function ksysgpooyamll() { & kubectl --namespace=kube-system get pods -o=yaml -l $args }
function kgdepoyamll() { & kubectl get deployment -o=yaml -l $args }
function ksysgdepoyamll() { & kubectl --namespace=kube-system get deployment -o=yaml -l $args }
function kgsvcoyamll() { & kubectl get service -o=yaml -l $args }
function ksysgsvcoyamll() { & kubectl --namespace=kube-system get service -o=yaml -l $args }
function kgingoyamll() { & kubectl get ingress -o=yaml -l $args }
function ksysgingoyamll() { & kubectl --namespace=kube-system get ingress -o=yaml -l $args }
function kgcmoyamll() { & kubectl get configmap -o=yaml -l $args }
function ksysgcmoyamll() { & kubectl --namespace=kube-system get configmap -o=yaml -l $args }
function kgsecoyamll() { & kubectl get secret -o=yaml -l $args }
function ksysgsecoyamll() { & kubectl --namespace=kube-system get secret -o=yaml -l $args }
function kgnooyamll() { & kubectl get nodes -o=yaml -l $args }
function kgnsoyamll() { & kubectl get namespaces -o=yaml -l $args }
function kgowidel() { & kubectl get -o=wide -l $args }
function ksysgowidel() { & kubectl --namespace=kube-system get -o=wide -l $args }
function kgpoowidel() { & kubectl get pods -o=wide -l $args }
function ksysgpoowidel() { & kubectl --namespace=kube-system get pods -o=wide -l $args }
function kgdepowidel() { & kubectl get deployment -o=wide -l $args }
function ksysgdepowidel() { & kubectl --namespace=kube-system get deployment -o=wide -l $args }
function kgsvcowidel() { & kubectl get service -o=wide -l $args }
function ksysgsvcowidel() { & kubectl --namespace=kube-system get service -o=wide -l $args }
function kgingowidel() { & kubectl get ingress -o=wide -l $args }
function ksysgingowidel() { & kubectl --namespace=kube-system get ingress -o=wide -l $args }
function kgcmowidel() { & kubectl get configmap -o=wide -l $args }
function ksysgcmowidel() { & kubectl --namespace=kube-system get configmap -o=wide -l $args }
function kgsecowidel() { & kubectl get secret -o=wide -l $args }
function ksysgsecowidel() { & kubectl --namespace=kube-system get secret -o=wide -l $args }
function kgnoowidel() { & kubectl get nodes -o=wide -l $args }
function kgnsowidel() { & kubectl get namespaces -o=wide -l $args }
function kgojsonl() { & kubectl get -o=json -l $args }
function ksysgojsonl() { & kubectl --namespace=kube-system get -o=json -l $args }
function kgpoojsonl() { & kubectl get pods -o=json -l $args }
function ksysgpoojsonl() { & kubectl --namespace=kube-system get pods -o=json -l $args }
function kgdepojsonl() { & kubectl get deployment -o=json -l $args }
function ksysgdepojsonl() { & kubectl --namespace=kube-system get deployment -o=json -l $args }
function kgsvcojsonl() { & kubectl get service -o=json -l $args }
function ksysgsvcojsonl() { & kubectl --namespace=kube-system get service -o=json -l $args }
function kgingojsonl() { & kubectl get ingress -o=json -l $args }
function ksysgingojsonl() { & kubectl --namespace=kube-system get ingress -o=json -l $args }
function kgcmojsonl() { & kubectl get configmap -o=json -l $args }
function ksysgcmojsonl() { & kubectl --namespace=kube-system get configmap -o=json -l $args }
function kgsecojsonl() { & kubectl get secret -o=json -l $args }
function ksysgsecojsonl() { & kubectl --namespace=kube-system get secret -o=json -l $args }
function kgnoojsonl() { & kubectl get nodes -o=json -l $args }
function kgnsojsonl() { & kubectl get namespaces -o=json -l $args }
function kgsll() { & kubectl get --show-labels -l $args }
function ksysgsll() { & kubectl --namespace=kube-system get --show-labels -l $args }
function kgposll() { & kubectl get pods --show-labels -l $args }
function ksysgposll() { & kubectl --namespace=kube-system get pods --show-labels -l $args }
function kgdepsll() { & kubectl get deployment --show-labels -l $args }
function ksysgdepsll() { & kubectl --namespace=kube-system get deployment --show-labels -l $args }
function kgwl() { & kubectl get --watch -l $args }
function ksysgwl() { & kubectl --namespace=kube-system get --watch -l $args }
function kgpowl() { & kubectl get pods --watch -l $args }
function ksysgpowl() { & kubectl --namespace=kube-system get pods --watch -l $args }
function kgdepwl() { & kubectl get deployment --watch -l $args }
function ksysgdepwl() { & kubectl --namespace=kube-system get deployment --watch -l $args }
function kgsvcwl() { & kubectl get service --watch -l $args }
function ksysgsvcwl() { & kubectl --namespace=kube-system get service --watch -l $args }
function kgingwl() { & kubectl get ingress --watch -l $args }
function ksysgingwl() { & kubectl --namespace=kube-system get ingress --watch -l $args }
function kgcmwl() { & kubectl get configmap --watch -l $args }
function ksysgcmwl() { & kubectl --namespace=kube-system get configmap --watch -l $args }
function kgsecwl() { & kubectl get secret --watch -l $args }
function ksysgsecwl() { & kubectl --namespace=kube-system get secret --watch -l $args }
function kgnowl() { & kubectl get nodes --watch -l $args }
function kgnswl() { & kubectl get namespaces --watch -l $args }
function kgwoyamll() { & kubectl get --watch -o=yaml -l $args }
function ksysgwoyamll() { & kubectl --namespace=kube-system get --watch -o=yaml -l $args }
function kgpowoyamll() { & kubectl get pods --watch -o=yaml -l $args }
function ksysgpowoyamll() { & kubectl --namespace=kube-system get pods --watch -o=yaml -l $args }
function kgdepwoyamll() { & kubectl get deployment --watch -o=yaml -l $args }
function ksysgdepwoyamll() { & kubectl --namespace=kube-system get deployment --watch -o=yaml -l $args }
function kgsvcwoyamll() { & kubectl get service --watch -o=yaml -l $args }
function ksysgsvcwoyamll() { & kubectl --namespace=kube-system get service --watch -o=yaml -l $args }
function kgingwoyamll() { & kubectl get ingress --watch -o=yaml -l $args }
function ksysgingwoyamll() { & kubectl --namespace=kube-system get ingress --watch -o=yaml -l $args }
function kgcmwoyamll() { & kubectl get configmap --watch -o=yaml -l $args }
function ksysgcmwoyamll() { & kubectl --namespace=kube-system get configmap --watch -o=yaml -l $args }
function kgsecwoyamll() { & kubectl get secret --watch -o=yaml -l $args }
function ksysgsecwoyamll() { & kubectl --namespace=kube-system get secret --watch -o=yaml -l $args }
function kgnowoyamll() { & kubectl get nodes --watch -o=yaml -l $args }
function kgnswoyamll() { & kubectl get namespaces --watch -o=yaml -l $args }
function kgowidesll() { & kubectl get -o=wide --show-labels -l $args }
function ksysgowidesll() { & kubectl --namespace=kube-system get -o=wide --show-labels -l $args }
function kgpoowidesll() { & kubectl get pods -o=wide --show-labels -l $args }
function ksysgpoowidesll() { & kubectl --namespace=kube-system get pods -o=wide --show-labels -l $args }
function kgdepowidesll() { & kubectl get deployment -o=wide --show-labels -l $args }
function ksysgdepowidesll() { & kubectl --namespace=kube-system get deployment -o=wide --show-labels -l $args }
function kgslowidel() { & kubectl get --show-labels -o=wide -l $args }
function ksysgslowidel() { & kubectl --namespace=kube-system get --show-labels -o=wide -l $args }
function kgposlowidel() { & kubectl get pods --show-labels -o=wide -l $args }
function ksysgposlowidel() { & kubectl --namespace=kube-system get pods --show-labels -o=wide -l $args }
function kgdepslowidel() { & kubectl get deployment --show-labels -o=wide -l $args }
function ksysgdepslowidel() { & kubectl --namespace=kube-system get deployment --show-labels -o=wide -l $args }
function kgwowidel() { & kubectl get --watch -o=wide -l $args }
function ksysgwowidel() { & kubectl --namespace=kube-system get --watch -o=wide -l $args }
function kgpowowidel() { & kubectl get pods --watch -o=wide -l $args }
function ksysgpowowidel() { & kubectl --namespace=kube-system get pods --watch -o=wide -l $args }
function kgdepwowidel() { & kubectl get deployment --watch -o=wide -l $args }
function ksysgdepwowidel() { & kubectl --namespace=kube-system get deployment --watch -o=wide -l $args }
function kgsvcwowidel() { & kubectl get service --watch -o=wide -l $args }
function ksysgsvcwowidel() { & kubectl --namespace=kube-system get service --watch -o=wide -l $args }
function kgingwowidel() { & kubectl get ingress --watch -o=wide -l $args }
function ksysgingwowidel() { & kubectl --namespace=kube-system get ingress --watch -o=wide -l $args }
function kgcmwowidel() { & kubectl get configmap --watch -o=wide -l $args }
function ksysgcmwowidel() { & kubectl --namespace=kube-system get configmap --watch -o=wide -l $args }
function kgsecwowidel() { & kubectl get secret --watch -o=wide -l $args }
function ksysgsecwowidel() { & kubectl --namespace=kube-system get secret --watch -o=wide -l $args }
function kgnowowidel() { & kubectl get nodes --watch -o=wide -l $args }
function kgnswowidel() { & kubectl get namespaces --watch -o=wide -l $args }
function kgwojsonl() { & kubectl get --watch -o=json -l $args }
function ksysgwojsonl() { & kubectl --namespace=kube-system get --watch -o=json -l $args }
function kgpowojsonl() { & kubectl get pods --watch -o=json -l $args }
function ksysgpowojsonl() { & kubectl --namespace=kube-system get pods --watch -o=json -l $args }
function kgdepwojsonl() { & kubectl get deployment --watch -o=json -l $args }
function ksysgdepwojsonl() { & kubectl --namespace=kube-system get deployment --watch -o=json -l $args }
function kgsvcwojsonl() { & kubectl get service --watch -o=json -l $args }
function ksysgsvcwojsonl() { & kubectl --namespace=kube-system get service --watch -o=json -l $args }
function kgingwojsonl() { & kubectl get ingress --watch -o=json -l $args }
function ksysgingwojsonl() { & kubectl --namespace=kube-system get ingress --watch -o=json -l $args }
function kgcmwojsonl() { & kubectl get configmap --watch -o=json -l $args }
function ksysgcmwojsonl() { & kubectl --namespace=kube-system get configmap --watch -o=json -l $args }
function kgsecwojsonl() { & kubectl get secret --watch -o=json -l $args }
function ksysgsecwojsonl() { & kubectl --namespace=kube-system get secret --watch -o=json -l $args }
function kgnowojsonl() { & kubectl get nodes --watch -o=json -l $args }
function kgnswojsonl() { & kubectl get namespaces --watch -o=json -l $args }
function kgslwl() { & kubectl get --show-labels --watch -l $args }
function ksysgslwl() { & kubectl --namespace=kube-system get --show-labels --watch -l $args }
function kgposlwl() { & kubectl get pods --show-labels --watch -l $args }
function ksysgposlwl() { & kubectl --namespace=kube-system get pods --show-labels --watch -l $args }
function kgdepslwl() { & kubectl get deployment --show-labels --watch -l $args }
function ksysgdepslwl() { & kubectl --namespace=kube-system get deployment --show-labels --watch -l $args }
function kgwsll() { & kubectl get --watch --show-labels -l $args }
function ksysgwsll() { & kubectl --namespace=kube-system get --watch --show-labels -l $args }
function kgpowsll() { & kubectl get pods --watch --show-labels -l $args }
function ksysgpowsll() { & kubectl --namespace=kube-system get pods --watch --show-labels -l $args }
function kgdepwsll() { & kubectl get deployment --watch --show-labels -l $args }
function ksysgdepwsll() { & kubectl --namespace=kube-system get deployment --watch --show-labels -l $args }
function kgslwowidel() { & kubectl get --show-labels --watch -o=wide -l $args }
function ksysgslwowidel() { & kubectl --namespace=kube-system get --show-labels --watch -o=wide -l $args }
function kgposlwowidel() { & kubectl get pods --show-labels --watch -o=wide -l $args }
function ksysgposlwowidel() { & kubectl --namespace=kube-system get pods --show-labels --watch -o=wide -l $args }
function kgdepslwowidel() { & kubectl get deployment --show-labels --watch -o=wide -l $args }
function ksysgdepslwowidel() { & kubectl --namespace=kube-system get deployment --show-labels --watch -o=wide -l $args }
function kgwowidesll() { & kubectl get --watch -o=wide --show-labels -l $args }
function ksysgwowidesll() { & kubectl --namespace=kube-system get --watch -o=wide --show-labels -l $args }
function kgpowowidesll() { & kubectl get pods --watch -o=wide --show-labels -l $args }
function ksysgpowowidesll() { & kubectl --namespace=kube-system get pods --watch -o=wide --show-labels -l $args }
function kgdepwowidesll() { & kubectl get deployment --watch -o=wide --show-labels -l $args }
function ksysgdepwowidesll() { & kubectl --namespace=kube-system get deployment --watch -o=wide --show-labels -l $args }
function kgwslowidel() { & kubectl get --watch --show-labels -o=wide -l $args }
function ksysgwslowidel() { & kubectl --namespace=kube-system get --watch --show-labels -o=wide -l $args }
function kgpowslowidel() { & kubectl get pods --watch --show-labels -o=wide -l $args }
function ksysgpowslowidel() { & kubectl --namespace=kube-system get pods --watch --show-labels -o=wide -l $args }
function kgdepwslowidel() { & kubectl get deployment --watch --show-labels -o=wide -l $args }
function ksysgdepwslowidel() { & kubectl --namespace=kube-system get deployment --watch --show-labels -o=wide -l $args }
function kexn() { & kubectl exec -i -t --namespace $args }
function klon() { & kubectl logs -f --namespace $args }
function kpfn() { & kubectl port-forward --namespace $args }
function kgn() { & kubectl get --namespace $args }
function kdn() { & kubectl describe --namespace $args }
function krmn() { & kubectl delete --namespace $args }
function kgpon() { & kubectl get pods --namespace $args }
function kdpon() { & kubectl describe pods --namespace $args }
function krmpon() { & kubectl delete pods --namespace $args }
function kgdepn() { & kubectl get deployment --namespace $args }
function kddepn() { & kubectl describe deployment --namespace $args }
function krmdepn() { & kubectl delete deployment --namespace $args }
function kgsvcn() { & kubectl get service --namespace $args }
function kdsvcn() { & kubectl describe service --namespace $args }
function krmsvcn() { & kubectl delete service --namespace $args }
function kgingn() { & kubectl get ingress --namespace $args }
function kdingn() { & kubectl describe ingress --namespace $args }
function krmingn() { & kubectl delete ingress --namespace $args }
function kgcmn() { & kubectl get configmap --namespace $args }
function kdcmn() { & kubectl describe configmap --namespace $args }
function krmcmn() { & kubectl delete configmap --namespace $args }
function kgsecn() { & kubectl get secret --namespace $args }
function kdsecn() { & kubectl describe secret --namespace $args }
function krmsecn() { & kubectl delete secret --namespace $args }
function kgoyamln() { & kubectl get -o=yaml --namespace $args }
function kgpooyamln() { & kubectl get pods -o=yaml --namespace $args }
function kgdepoyamln() { & kubectl get deployment -o=yaml --namespace $args }
function kgsvcoyamln() { & kubectl get service -o=yaml --namespace $args }
function kgingoyamln() { & kubectl get ingress -o=yaml --namespace $args }
function kgcmoyamln() { & kubectl get configmap -o=yaml --namespace $args }
function kgsecoyamln() { & kubectl get secret -o=yaml --namespace $args }
function kgowiden() { & kubectl get -o=wide --namespace $args }
function kgpoowiden() { & kubectl get pods -o=wide --namespace $args }
function kgdepowiden() { & kubectl get deployment -o=wide --namespace $args }
function kgsvcowiden() { & kubectl get service -o=wide --namespace $args }
function kgingowiden() { & kubectl get ingress -o=wide --namespace $args }
function kgcmowiden() { & kubectl get configmap -o=wide --namespace $args }
function kgsecowiden() { & kubectl get secret -o=wide --namespace $args }
function kgojsonn() { & kubectl get -o=json --namespace $args }
function kgpoojsonn() { & kubectl get pods -o=json --namespace $args }
function kgdepojsonn() { & kubectl get deployment -o=json --namespace $args }
function kgsvcojsonn() { & kubectl get service -o=json --namespace $args }
function kgingojsonn() { & kubectl get ingress -o=json --namespace $args }
function kgcmojsonn() { & kubectl get configmap -o=json --namespace $args }
function kgsecojsonn() { & kubectl get secret -o=json --namespace $args }
function kgsln() { & kubectl get --show-labels --namespace $args }
function kgposln() { & kubectl get pods --show-labels --namespace $args }
function kgdepsln() { & kubectl get deployment --show-labels --namespace $args }
function kgwn() { & kubectl get --watch --namespace $args }
function kgpown() { & kubectl get pods --watch --namespace $args }
function kgdepwn() { & kubectl get deployment --watch --namespace $args }
function kgsvcwn() { & kubectl get service --watch --namespace $args }
function kgingwn() { & kubectl get ingress --watch --namespace $args }
function kgcmwn() { & kubectl get configmap --watch --namespace $args }
function kgsecwn() { & kubectl get secret --watch --namespace $args }
function kgwoyamln() { & kubectl get --watch -o=yaml --namespace $args }
function kgpowoyamln() { & kubectl get pods --watch -o=yaml --namespace $args }
function kgdepwoyamln() { & kubectl get deployment --watch -o=yaml --namespace $args }
function kgsvcwoyamln() { & kubectl get service --watch -o=yaml --namespace $args }
function kgingwoyamln() { & kubectl get ingress --watch -o=yaml --namespace $args }
function kgcmwoyamln() { & kubectl get configmap --watch -o=yaml --namespace $args }
function kgsecwoyamln() { & kubectl get secret --watch -o=yaml --namespace $args }
function kgowidesln() { & kubectl get -o=wide --show-labels --namespace $args }
function kgpoowidesln() { & kubectl get pods -o=wide --show-labels --namespace $args }
function kgdepowidesln() { & kubectl get deployment -o=wide --show-labels --namespace $args }
function kgslowiden() { & kubectl get --show-labels -o=wide --namespace $args }
function kgposlowiden() { & kubectl get pods --show-labels -o=wide --namespace $args }
function kgdepslowiden() { & kubectl get deployment --show-labels -o=wide --namespace $args }
function kgwowiden() { & kubectl get --watch -o=wide --namespace $args }
function kgpowowiden() { & kubectl get pods --watch -o=wide --namespace $args }
function kgdepwowiden() { & kubectl get deployment --watch -o=wide --namespace $args }
function kgsvcwowiden() { & kubectl get service --watch -o=wide --namespace $args }
function kgingwowiden() { & kubectl get ingress --watch -o=wide --namespace $args }
function kgcmwowiden() { & kubectl get configmap --watch -o=wide --namespace $args }
function kgsecwowiden() { & kubectl get secret --watch -o=wide --namespace $args }
function kgwojsonn() { & kubectl get --watch -o=json --namespace $args }
function kgpowojsonn() { & kubectl get pods --watch -o=json --namespace $args }
function kgdepwojsonn() { & kubectl get deployment --watch -o=json --namespace $args }
function kgsvcwojsonn() { & kubectl get service --watch -o=json --namespace $args }
function kgingwojsonn() { & kubectl get ingress --watch -o=json --namespace $args }
function kgcmwojsonn() { & kubectl get configmap --watch -o=json --namespace $args }
function kgsecwojsonn() { & kubectl get secret --watch -o=json --namespace $args }
function kgslwn() { & kubectl get --show-labels --watch --namespace $args }
function kgposlwn() { & kubectl get pods --show-labels --watch --namespace $args }
function kgdepslwn() { & kubectl get deployment --show-labels --watch --namespace $args }
function kgwsln() { & kubectl get --watch --show-labels --namespace $args }
function kgpowsln() { & kubectl get pods --watch --show-labels --namespace $args }
function kgdepwsln() { & kubectl get deployment --watch --show-labels --namespace $args }
function kgslwowiden() { & kubectl get --show-labels --watch -o=wide --namespace $args }
function kgposlwowiden() { & kubectl get pods --show-labels --watch -o=wide --namespace $args }
function kgdepslwowiden() { & kubectl get deployment --show-labels --watch -o=wide --namespace $args }
function kgwowidesln() { & kubectl get --watch -o=wide --show-labels --namespace $args }
function kgpowowidesln() { & kubectl get pods --watch -o=wide --show-labels --namespace $args }
function kgdepwowidesln() { & kubectl get deployment --watch -o=wide --show-labels --namespace $args }
function kgwslowiden() { & kubectl get --watch --show-labels -o=wide --namespace $args }
function kgpowslowiden() { & kubectl get pods --watch --show-labels -o=wide --namespace $args }
function kgdepwslowiden() { & kubectl get deployment --watch --show-labels -o=wide --namespace $args }
