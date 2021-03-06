import ma = require('vsts-task-lib/mock-answer');
import tmrm = require('vsts-task-lib/mock-run');
import path = require('path');

let taskPath = path.join(__dirname, '..', 'gradletask.js');
let tr: tmrm.TaskMockRunner = new tmrm.TaskMockRunner(taskPath);

tr.setInput('wrapperScript', 'gradlew');
tr.setInput('options', '');
tr.setInput('tasks', 'build FAIL');
tr.setInput('javaHomeSelection', 'JDKVersion');
tr.setInput('jdkVersion', 'default');
tr.setInput('publishJUnitResults', 'true');
tr.setInput('testResultsFiles', '**/build/test-results/TEST-*.xml');

// provide answers for task mock
let a: ma.TaskLibAnswers = <ma.TaskLibAnswers>{
    'checkPath': {
        'gradlew': true,
        'gradlew.bat': true
    },
    'exec': {
        'gradlew build FAIL': {
            'code': 2,
            'stderr': 'FAILED'
        },
        'gradlew.bat build FAIL': {
            'code': 2,
            'stderr': 'FAILED'
        }
    },
    'match': {
        '**/build/test-results/TEST-*.xml': [
            '/user/build/fun/test-results/test-123.xml'
        ]
    }
};
tr.setAnswers(a);

tr.run();
