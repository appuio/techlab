# Using oc cli

Log into the Webconsole and get familiar with the interface.

A project is a grouping of resources (container and docker images, pods, services, routes, configuration, quotas, limits and more). Users authorized for the project can manage these resources. Within an OpenShift cluster, the name of a project must be unique.
Create a new project from the webui called:

    [USER]-webui

## Log in on the cli

Copy the login command from the Webconsole (did you find this option? -> in the menu on the right hand side).

    oc login https://[CLUSTER_URL] --token=XYZ
    oc whoami

The token allows you to have a logged in session and can be used to do logins from the cli (on the API), without doing the authentication there.

Once you are logged in let's get familiar with the CLI and its commands:

## Getting help

oc cli features a help output, as well as more detailed help for each command:

    oc help
    oc projects -h
    oc projects

## Create a new project on the cli

Create a project called `cli-[USER]`

You can get help by

    oc new-project -h

<details><summary>Solution</summary>oc new-project [USER]-cli</details><br/>

We are immediately switched to our project:

    oc project

We can inspect our project by either describing it or getting a yaml (or json) formatted output of our created project.

    oc describe project cli-[USER]
    oc get project webui-[USER] -o yaml
    oc get project webui-[USER] -o json

## Adding users to a project

Openshift can have multiple users (also with different roles) on the same projects. For that we can add individual users on the project or we can also add a group of users to a project.

Users or groups can have different roles either within the whole cluster or locally within a project.

Find more about roles [here](https://docs.openshift.com/container-platform/4.3/authentication/using-rbac.html) and how to manage them [here](https://docs.openshift.com/container-platform/4.3/authentication/using-rbac.html#viewing-cluster-roles_using-rbac)

To see all the active roles in your current project you can type:

    oc describe rolebinding.rbac

For your webui project:

    oc describe rolebinding.rbac -n webui-[USER]

We can manage roles by issuing `oc adm policy` commands:

    oc adm policy -h

For this lab there is a group called `techlab`, where all workshop users are being part of.

Let's add this group as an admin role to our current project, so we can co-develop things within these projects.

    oc adm policy add-role-to-group -h
    oc adm policy add-role-to-group admin techlab -n cli-[USER]

Too much privileges? At least for our webui projects, so let's add folks there only as viewer:

    oc adm policy add-role-to-group view techlab -n webui-[USER]

You can also remove the previous access rights of the `cli-[USER]` project:

    oc adm policy remove-role-from-group admin techlab -n cli-[USER]

How many others did add us to their projects? Let's see by get the current list of projects:

    oc projects

Check the changes in the Web Console. Go to both of your projects and find the techlab group under _Resources -> Membership_

## Inspecting and editing other resources

Everything within Openshift (Kubernetes) is represented as a resource, which we can view and depending on our privileges/role edit.

You can get all resources of your current project, by typing:

    oc get all

You don't see anything? Or get "No resources found."
This is because we haven't deployed anything yet. You can deploy a simple application and redo the `oc get` command:

    oc new-app https://github.com/appuio/example-php-sti-helloworld.git

You can also get all resources of all namespaces (projects) you have access to:

    oc get all -n [NAMESPACE]

Found an interesting resource you want to know about it, you can `describe/get` each one of them:

    oc describe [RESOURCE_TYPE] [RESOURCE_NAME]

You can also edit them:

    oc edit [RESOURCE_TYPE] [RESOURCE_NAME]

For example let's edit our webui project:

    oc edit project webui-[USER]

This was only an example. Quit the editor by entering: _ESC_ and _:_ and _q_

## Deleting resources

Not happy about how things went in your current projects and want to start over?

    oc delete project webui-[USER]

This will delete all resources bundled by this project. Projects are really an easy way to try things out and once you are done easily clean it up.

## How are my resources doing?

You can always get an overview of your current resources by typing:

    oc status

This will become latery handy, once we start deploying more things.
