# generated from @template_name

@{os_code_name = 'focal'}@
FROM ubuntu:@os_code_name

ARG GITLAB_TOKEN
VOLUME ["/var/cache/apt/archives"]

ENV DEBIAN_FRONTEND noninteractive

@(TEMPLATE(
    'snippet/setup_locale.Dockerfile.em',
    timezone=timezone,
))@

RUN useradd -u @uid -l -m buildfarm

@(TEMPLATE(
    'snippet/add_distribution_repositories.Dockerfile.em',
    distribution_repository_keys=distribution_repository_keys,
    distribution_repository_urls=distribution_repository_urls,
    os_name='ubuntu',
    os_code_name=os_code_name,
    add_source=False,
))@

@(TEMPLATE(
    'snippet/add_wrapper_scripts.Dockerfile.em',
    wrapper_scripts=wrapper_scripts,
))@

# automatic invalidation once every day
RUN echo "@today_str"

@(TEMPLATE(
    'snippet/install_python3.Dockerfile.em',
    os_name='ubuntu',
    os_code_name=os_code_name,
))@

# Require to create a jenkins credential with Gitlab TOKEN and bind it with the variable GITLAB_TOKEN
RUN echo GITLAB_TOKEN=$GITLAB_TOKEN > .env
RUN python3 -u /tmp/wrapper_scripts/apt.py update-install-clean -q -y git python3-catkin-pkg-modules python3-rosdistro python3-yaml python3-pip wget
RUN pip3 install python-gitlab python-dotenv
RUN git clone https://github.com/lozeki/rosdistro.git; cd rosdistro; pip3 install . --upgrade --target=/usr/lib/python3/dist-packages
USER buildfarm
ENTRYPOINT ["sh", "-c"]
@{
cmds = [
    'cd /tmp/rosdistro_cache',
    'python3 -u' +
    ' /usr/bin/rosdistro_build_cache' +
    ' ' + rosdistro_index_url +
    ' ' + rosdistro_name +
    ' --debug --ignore-local'
]
}@
CMD ["@(' && '.join(cmds))"]
