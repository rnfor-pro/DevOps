### Introduction
---

### Prerequisites
- Access to a server with at least 2GB of RAM and Docker installed.

## Step 1 — Disabling the Setup Wizard

[github-manual](https://github.com/jenkinsci/configuration-as-code-plugin/tree/master)

[manual](https://www.digitalocean.com/community/tutorials/how-to-automate-jenkins-setup-with-docker-and-jenkins-configuration-as-code#conclusion)

### Step 2 — Installing Jenkins Plugins

This is the corrected dockerfile, the one in the url above doesn't work.

```bash
FROM jenkins/jenkins:lts
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt
```
### Step 3 — Specifying the Jenkins URL

create a new file named casc.yaml
```bash
nano $HOME/playground/jcasc/casc.yaml
```

Add the following lines

```bash
unclassified:
  location:
    url: http://server_ip:8080/
```
`unclassified.location.url` is the path for setting the Jenkins URL

Add a COPY instruction to the end of your Dockerfile that copies the casc.yaml file into the image at /var/jenkins_home/casc.yaml. You’ve chosen /var/jenkins_home/ because that’s the default directory where Jenkins stores all of its data:

```bash
FROM jenkins/jenkins:lts
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt
COPY casc.yaml /var/jenkins_home/casc.yaml
```
Then, add a further ENV instruction that sets the CASC_JENKINS_CONFIG environment variable:

```bash
FROM jenkins/jenkins:lts
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt
COPY casc.yaml /var/jenkins_home/casc.yaml
```

Save the file and exit the editor. Next, build the image:

```
docker build -t jenkins:jcasc .
```

And run the updated Jenkins image:

```
docker run --name jenkins --rm -p 8080:8080 jenkins:jcasc
```

Now, navigate to server_ip:8080/configure and scroll down to the Jenkins URL field. Confirm that the Jenkins URL has been set to the same value specified in the casc.yaml file.

Lastly, stop the container process by pressing CTRL+C.

### Step 4 — Creating a User

So far, your setup has not implemented any authentication and authorization mechanisms. In this step, you will set up a basic, password-based authentication scheme and create a new user named admin.

Start by opening your casc.yaml file:

```
nano $HOME/playground/jcasc/casc.yaml
```
Then, add in the highlighted snippet:

```bash
jenkins:
  securityRealm:
    local:
      allowsSignup: false
      users:
       - id: ${JENKINS_ADMIN_ID}
         password: ${JENKINS_ADMIN_PASSWORD}
unclassified:
  location:
    url: http://server_ip:8080/
```

In the context of Jenkins, a security realm is simply an authentication mechanism; the local security realm means to use basic authentication where users must specify their ID/username and password. Other security realms exist and are provided by plugins. For instance, the LDAP plugin allows you to use an existing LDAP directory service as the authentication mechanism. The GitHub Authentication plugin allows you to use your GitHub credentials to authenticate via OAuth.

Note that you’ve also specified allowsSignup: false, which prevents anonymous users from creating an account through the web interface.

Finally, instead of hard-coding the user ID and password, you are using variables whose values can be filled in at runtime. This is important because one of the benefits of using JCasC is that the casc.yaml file can be committed into source control; if you were to store user passwords in plaintext inside the configuration file, you would have effectively compromised the credentials. Instead, variables are defined using the ${VARIABLE_NAME} syntax, and its value can be filled in using an environment variable of the same name, or a file of the same name that’s placed inside the /run/secrets/ directory within the container image.

Next, build a new image to incorporate the changes made to the casc.yaml file:

```
docker build -t jenkins:jcasc .
```
Then, run the updated Jenkins image whilst passing in the JENKINS_ADMIN_ID and JENKINS_ADMIN_PASSWORD environment variables via the --env option (replace <password> with a password of your choice):

```
docker run --name jenkins --rm -p 8080:8080 --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD=password jenkins:jcasc
```

You can now go to server_ip:8080/login and log in using the specified credentials.

Finish this step by pressing CTRL+C to stop the container.

In this step, you used JCasC to create a new user named admin. You’ve also learned how to keep sensitive data, like passwords, out of files tracked by VCSs. However, so far you’ve only configured user authentication; you haven’t implemented any authorization mechanisms. In the next step, you will use JCasC to grant your admin user with administrative privileges.

### Step 5 — Setting Up Authorization

By default, the Jenkins core installation provides us with three authorization strategies:

unsecured: every user, including anonymous users, have full permissions to do everything
legacy: emulates legacy Jenkins (prior to v1.164), where any users with the role admin is given full permissions, whilst other users, including anonymous users, are given read access.

loggedInUsersCanDoAnything: anonymous users are given either no access or read-only access. Authenticated users have full permissions to do everything. By allowing actions only for authenticated users, you are able to have an audit trail of which users performed which actions.

All of these authorization strategies are very crude, and does not afford granular control over how permissions are set for different users. Instead, you can use the Matrix Authorization Strategy plugin that was already included in your plugins.txt list. This plugin affords you a more granular authorization strategy, and allows you to set user permissions globally, as well as per project/job.

The Matrix Authorization Strategy plugin allows you to use the jenkins.authorizationStrategy.globalMatrix.permissions JCasC property to set global permissions. To use it, open your casc.yaml file:

```
nano $HOME/playground/jcasc/casc.yaml
```

And add in the highlighted snippet:


```bash
jenkins:
  securityRealm:
    local:
      allowsSignup: false
      users:
       - id: ${JENKINS_ADMIN_ID}
         password: ${JENKINS_ADMIN_PASSWORD}
   authorizationStrategy:
    globalMatrix:
      permissions:
        - "Overall/Administer:admin"
        - "Overall/Read:authenticated"
unclassified:
  location:
    url: http://server_ip:8080/
```
The globalMatrix property sets global permissions (as opposed to per-project permissions). The permissions property is a list of strings with the format <permission-group>/<permission-name>:<role>. Here, you are granting the Overall/Administer permissions to the admin user. You’re also granting Overall/Read permissions to authenticated, which is a special role that represents all authenticated users. There’s another special role called anonymous, which groups all non-authenticated users together. But since permissions are denied by default, if you don’t want to give anonymous users any permissions, you don’t need to explicitly include an entry for it.

Save the casc.yaml file, exit your editor, and build a new image:

```
docker build -t jenkins:jcasc .
```

Then, run the updated Jenkins image:

```
docker run --name jenkins --rm -p 8080:8080 --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD=password jenkins:jcasc
```

### Step 6 — Setting Up Build Authorization

The first issue in the notifications list relates to build authentication. By default, all jobs are run as the system user, which has a lot of system privileges. Therefore, a Jenkins user can perform privilege escalation simply by defining and running a malicious job or pipeline; this is insecure.

Instead, jobs should be ran using the same Jenkins user that configured or triggered it. To achieve this, you need to install an additional plugin called the Authorize Project plugin.

Open plugins.txt:

```
nano $HOME/playground/jcasc/plugins.txt
```

And add the plugin below
`authorize-project:latest`

The plugin provides a new build authorization strategy, which you would need to specify in your JCasC configuration. Exit out of the plugins.txt file and open the casc.yaml file:

`
nano $HOME/playground/jcasc/casc.yaml
`
Add the highlighted block to your casc.yaml file:

```bash
...
        - "Overall/Administer:admin"
        - "Overall/Read:authenticated"
security:
  queueItemAuthenticator:
    authenticators:
    - global:
        strategy: triggeringUsersAuthorizationStrategy
unclassified:
...
```

```yaml
jenkins:
  securityRealm:
    local:
      allowsSignup: false
      users:
       - id: ${JENKINS_ADMIN_ID}
         password: ${JENKINS_ADMIN_PASSWORD}
  authorizationStrategy:
    globalMatrix:
      permissions:
        - "Overall/Administer:admin"
        - "Overall/Read:authenticated"
security:
  queueItemAuthenticator:
    authenticators:
    - global:
        strategy: triggeringUsersAuthorizationStrategy 
unclassified:
  location:
    url: http://server_ip:8080/

```
Save the file and exit the editor. Then, build a new image using the modified plugins.txt and casc.yaml files:

```
docker build -t jenkins:jcasc .
```
Then, run the updated Jenkins image:

```bash
docker run --name jenkins --rm -p 8080:8080 --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD=password jenkins:jcasc
```

Wait for the Jenkins is fully up and running log line, then navigate to server_ip:8080/login, fill in your credentials, and arrive at the main dashboard. Open the notification menu, and you will see the issue related to build authentication no longer appears.

### Step 7 — Enabling Agent to Controller Access Control

In this tutorial, you have deployed only a single instance of Jenkins, which runs all builds. However, Jenkins supports distributed builds using an agent/controller configuration. The controller is responsible for providing the web UI, exposing an API for clients to send requests to, and co-ordinating builds. The agents are the instances that execute the jobs.

The benefit of this configuration is that it is more scalable and fault-tolerant. If one of the servers running Jenkins goes down, other instances can take up the extra load.

However, there may be instances where the agents cannot be trusted by the controller. For example, the OPS team may manage the Jenkins controller, whilst an external contractor manages their own custom-configured Jenkins agent. Without the Agent to Controller Security Subsystem, the agent is able to instruct the controller to execute any actions it requests, which may be undesirable. By enabling Agent to Controller Access Control, you can control which commands and files the agents have access to.

To enable Agent to Controller Access Control, open the casc.yaml file:

```
nano $HOME/playground/jcasc/casc.yaml
```

Then, add the following highlighted lines:

```yaml
...
        - "Overall/Administer:admin"
        - "Overall/Read:authenticated"
  remotingSecurity:
    enabled: true
security:
  queueItemAuthenticator:
...
```

to have 

```yaml
jenkins:
  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: ${JENKINS_ADMIN_ID}
          password: ${JENKINS_ADMIN_PASSWORD}
  authorizationStrategy:
    globalMatrix:
      permissions:
        - "Overall/Administer:admin"
        - "Overall/Read:authenticated"
  remotingSecurity:
    enabled: true
security:
  queueItemAuthenticator:
    authenticators:
      - global:
          strategy: triggeringUsersAuthorizationStrategy 
unclassified:
  location:
    url: http://server_ip:8080/

```

Save the file and build a new image:

```
docker build -t jenkins:jcasc .
```

Run the updated Jenkins image:

```
docker run --name jenkins --rm -p 8080:8080 --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD=password jenkins:jcasc
```

Navigate to server_ip:8080/login and authenticate as before. When you land on the main dashboard, the notifications menu will not show any more issues.

### Conclusion

You’ve now successfully configured a simple Jenkins server using JCasC. Just as the Pipeline plugin enables developers to define their jobs inside a Jenkinsfile, the Configuration as Code plugin enables administrators to define the Jenkins configuration inside a YAML file. Both of these plugins bring Jenkins closer aligned with the Everything as Code (EaC) paradigm.

However, getting the JCasC syntax correct can be difficult, and the documentation can be hard to decipher. If you’re stuck and need help, you may find it in the [Gitter chat](https://app.gitter.im/#/room/#jenkinsci_configuration-as-code-plugin:gitter.im) for the plugin.


Although you have configured the basic settings of Jenkins using JCasC, the new instance does not contain any projects or jobs. To take this even further, explore the Job DSL plugin, which allows us to define projects and jobs as code. What’s more, you can include the [Job DSL](https://www.digitalocean.com/community/tutorials/how-to-automate-jenkins-job-configuration-using-job-dsl) code inside your JCasC configuration file, and have the projects and jobs created as part of the configuration process.