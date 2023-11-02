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
RUN echo $TOKEN > my_token.txt
RUN python3 -u /tmp/wrapper_scripts/apt.py update-install-clean -q -y git python3-catkin-pkg-modules python3-rosdistro python3-yaml python3-pip wget
RUN pip3 install python-gitlab
RUN python3 -V
RUN git clone https://github.com/lozeki/rosdistro.git; cd rosdistro; pip3 install . --upgrade --target=/usr/lib/python3/dist-packages
RUN git clone https://gitlab.fel.cvut.cz/cras/ros-release/cras_imu_tools.git
#RUN git clone https://oauth2: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@github.com/lozeki/ros_buildfarm_config.git
#RUN git clone http://oauth2:glpat-kTETAcDJ7Bv_vsBTyyvF@gitlab.halo.dekaresearch.com/kiwi/device/build/ros/rosdistro_setup.git
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
