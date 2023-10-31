# generated from @template_name

@{os_code_name = 'focal'}@
FROM ubuntu:@os_code_name

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
RUN export GITLAB_TOKEN=$GITLAB_TOKEN
RUN python3 -u /tmp/wrapper_scripts/apt.py update-install-clean -q -y git python3-catkin-pkg-modules python3-rosdistro python3-yaml python3-pip wget
#RUN git clone http://oauth2:$GITLAB_TOKEN@gitlab.halo.dekaresearch.com/kiwi/device/build/ros/rosdistro.git ; cd rosdistro; pip3 install . --upgrade --target=/usr/lib/python3/dist-packages
RUN git clone http://oauth2:$GITLAB_TOKEN@gitlab.halo.dekaresearch.com/kiwi/device/build/ros/rosdistro_setup.git; cd rosdistro_setup; pip3 install . --upgrade --target=/usr/lib/python3/dist-packages
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
