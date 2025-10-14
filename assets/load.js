import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
    stages: [
        { duration: '10s', target: 20 },   
        { duration: '20s', target: 50 },  
        { duration: '30s', target: 80 },
        { duration: '180s', target: 150 },
    ]
};

export default function () {
    let res = http.get('http://moc.cquinta.com');

    check(res, {
        'Status 200': (r) => r.status === 200,
        'Tempo de resposta < 500ms': (r) => r.timings.duration < 500,
    });

    sleep(1); // Pequeno tempo de espera entre as requisições
}