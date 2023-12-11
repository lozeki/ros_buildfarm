    <com.cloudbees.jenkins.plugins.sshagent.SSHAgentBuildWrapper plugin="ssh-agent@@1.17">
      <credentialIds>
        @[if "100d" in credential_ids]@
          <string>100d</string>
        @[else]@
        @[for credential_id in credential_ids]@
          <string>@credential_id</string>
        @[end for]@
        @[end if]@
      </credentialIds>
      <ignoreMissing>false</ignoreMissing>
    </com.cloudbees.jenkins.plugins.sshagent.SSHAgentBuildWrapper>
