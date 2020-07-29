# Using oc cli

Log into the Webconsole: [https://console-openshift-console.apps.cluster-centris-0c77.centris-0c77.example.opentlc.com](https://console-openshift-console.apps.cluster-centris-0c77.centris-0c77.example.opentlc.com) and get familiar with the interface.

Additionally, also visit the kibana URL to have it at hand. [kibana-openshift-logging.apps.cluster-centris-0c77.centris-0c77.example.opentlc.com](https://kibana-openshift-logging.apps.cluster-centris-0c77.centris-0c77.example.opentlc.com)

Ok, let's move over to do something:

A project is a grouping of resources (container and docker images, pods, services, routes, configuration, quotas, limits and more). Users authorized for the project can manage these resources. Within an OpenShift cluster, the name of a project must be unique.
Create a new project from the webui called:

    webui-userXY

## Log in on the cli

Copy the login command from the Webconsole (did you find this option? -> in the menu on the right hand side).

    oc login https://api.cluster-centris-0c77.centris-0c77.example.opentlc.com:6443 --token=XYZ
    oc whoami

The token allows you to have a logged in session and can be used to do logins from the cli (on the API), without doing the authentication there.

Once you are logged in let's get familiar with the CLI and its commands:

## Getting help

oc cli features a help output, as well as more detailed help for each command:

    oc help
    oc projects -h
    oc projects

## Create a new project on the cli

Create a project called `cli-userXY`

You can get help by

    oc new-project -h

We are immediately switched to our project:

    oc project

We can inspect our project by either describing it or getting a yaml (or json) formatted output of our created project.

    oc describe project cli-userXY
    oc get project webui-userXY -o yaml
    oc get project webui-userXY -o json

## Adding users to a project

Openshift can have multiple users (also with different roles) on the same projects. For that we can add individual users on the project or we can also add a group of users to a project.

Users or groups can have different roles either within the whole cluster or locally within a project.

Find more about roles [here](https://docs.openshift.com/container-platform/4.3/authentication/using-rbac.html) and how to manage them [here](https://docs.openshift.com/container-platform/4.3/authentication/using-rbac.html#viewing-cluster-roles_using-rbac)

To see all the active roles in your current project you can type:

    oc describe rolebinding.rbac

For your webui project:

    oc describe rolebinding.rbac -n webui-userXY

We can manage roles by issuing oc adm policy commands:

    oc adm policy -h

For this lab there is a group called `techlab`, where all workshop users are being part of.

Let's add this group as an admin role to our current project, so we can co-develop things within these projects.

    oc adm policy add-role-to-group -h
    oc adm policy add-role-to-group admin techlab -n cli-userXY

Too much privileges? At least for our webui projects, so let's add folks there only as viewer:

    oc adm policy add-role-to-group view techlab -n webui-userXY

You can also remove the previous access rights of the cli-userXY project:

    oc adm policy remove-role-from-group admin techlab -n cli-userXY

How many others did add us to their projects? Let's see by get the current list of projects:

    oc projects

## Inspecting and editing other resources

Everything within Openshift (Kubernetes) is represented as a resource, which we can view and depending on our privileges/role edit.

You can get all resources of your current project, by typing:

    oc get all

You don't see anything? Or get "No resources found."
This is because we haven't deployed anything yet. You can deploy a simple application and redo the oc get command:

    oc new-app ruby:2.5~https://git.apps.cluster-centris-0c77.centris-0c77.example.opentlc.com/training/ruby-ex.git

You can also get all resources of all namespaces (projects) you have access to:

    oc get all -n gogs

Found an interesting resource you want to know about it, you can describe/get each one of them:

    oc describe resourceXY resourceName

You can also edit them:

    oc edit resourceXY resourceName

For example let's edit our webui project:

    oc edit project webui-userXY

## Deleting resources

Not happy about how things went in your current projects and want to start over?

    oc delete project webui-userXY

This will delete all resources bundled by this project. Projects are really an easy way to try things out and once you are done easily clean it up.

## How are my resources doing?

You can always get an overview of your current resources by typing:

    oc status

This will become latery handy, once we start deploying more things.
