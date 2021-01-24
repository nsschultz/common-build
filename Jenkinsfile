def IMAGES = [
    'base-csharp-builder',
    'base-csharp-runner',
    'base-nginx-runner'
]

def buildAndPublishImage(image, version, userName, password) {
    sh  """
        #!/bin/bash
        docker build --target ${image} -t nschultz/${image}:${version} .
        docker login -u ${userName} -p ${password}
        docker push nschultz/${image}:${version}
        docker logout
        """
}

pipeline {
    agent { label 'builder' }
    environment {
        VERSION_NUMBER = '0.5.3'
        IMAGE_VERSION = "${GIT_BRANCH == "main" ? VERSION_NUMBER : VERSION_NUMBER+"-"+GIT_BRANCH}"
        DOCKER_HUB = credentials("dockerhub-creds")
    }
    stages {
        stage('build and publish') { 
            steps { script {
                def jobs = [:]
                IMAGES.each { image -> jobs["build and publish ${image}"] = { 
                    def tempImageName = image
                    node { stage("build and publish ${tempImageName}") { 
                        checkout scm
                        buildAndPublishImage(tempImageName, IMAGE_VERSION, DOCKER_HUB_USR, DOCKER_HUB_PSW) 
                } } } }
                parallel jobs
            } } 
        }
    }
    post { always { script { sh("docker builder prune -f --filter \'unused-for=24h\'") } } }
}