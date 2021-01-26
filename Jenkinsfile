def IMAGES = [
    'base-csharp-builder': '5.0.0',
    'base-csharp-runner': '5.0.0',
    'base-nginx-runner': '1.18.0'
]

def buildAndPublishImage(image, baseVersion, userName, password) {
    def version = "${GIT_BRANCH == "main" ? baseVersion : baseVersion+"-"+GIT_BRANCH}"
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
    environment { DOCKER_HUB = credentials("dockerhub-creds") }
    stages {
        stage('build and publish') { 
            steps { script {
                def jobs = [:]
                IMAGES.each { entry -> jobs["build and publish ${entry.key}"] = { 
                    def tempImageName = entry.key
                    node { stage("build and publish ${tempImageName}") { 
                        checkout scm
                        buildAndPublishImage(tempImageName, entry.value, DOCKER_HUB_USR, DOCKER_HUB_PSW) 
                } } } }
                parallel jobs
            } } 
        }
    }
    post { always { script { sh("docker builder prune -f --filter \'unused-for=24h\'") } } }
}