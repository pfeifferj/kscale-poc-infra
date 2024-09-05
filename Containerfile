FROM registry.access.redhat.com/ubi9/ubi:latest AS builder

RUN dnf update -y && \
    dnf install -y ansible-core ansible-galaxy git && \
    dnf clean all

RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

RUN ansible-galaxy collection install kubernetes.core community.general

RUN ansible-galaxy collection install \
    kubernetes.core.helm \
    community.general.terraform \
    kubernetes.core.k8s

COPY ./ansible /workspace/ansible
COPY ./helm /workspace/helm
COPY ./terraform /workspace/terraform

FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

COPY --from=builder /usr/local/bin/helm /usr/local/bin/helm
COPY --from=builder /usr/local/bin/ansible* /usr/local/bin/
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=builder /workspace /workspace

WORKDIR /workspace

ARG API_TOKEN
ENV API_TOKEN=${API_TOKEN}

VOLUME ["/output_logs"]

CMD ["bash", "-c", "ansible-playbook -i /workspace/ansible/inventory /workspace/ansible/playbook.yml --extra-vars \"api_token=${API_TOKEN}\" | tee /output_logs/playbook_output.log"]