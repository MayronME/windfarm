import boto3
import json
import random 
import string 
from datetime import datetime
import time

aws_credentials_path  = r'/home/mayron/.aws/credentials'

AWS_ACCESS_KEY_ID     = open(aws_credentials_path).read().split()[3]
AWS_SECRET_ACCESS_KEY = open(aws_credentials_path).read().split()[-1]

cliente = boto3.client(
    'kinesis',
    aws_access_key_id=AWS_ACCESS_KEY_ID,
    aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    region_name='us-east-1'
)
if 'cliente' in globals():
    print('Conexão com o Kinesis Estabelecida')
else:
    exit()

while True:
    id = ''.join([random.choice(string.ascii_letters + string.digits) for n in range(32)])
    # Dados Simulador do Power Factor
    dados = random.uniform(0.7,1)
    registro_p = {
        'idtemp': str(id),
        'data': str(dados),
        'type': 'powerfactor',
        'timestamp': str(datetime.now())
    }
    
    # Dados Simulador do Temperature Bettery
    dados = random.uniform(20,25)
    registro_t = {
        'idtemp': str(id),
        'data': str(dados),
        'type': 'tempeature',
        'timestamp': str(datetime.now())
    }

    # Dados Simulador do Hydraulic Pressure
    dados = random.uniform(70,80)
    registro_h = {
        'idtemp': str(id),
        'data': str(dados),
        'type': 'hydraulicpressure',
        'timestamp': str(datetime.now())
    }

    for registro in [registro_p,registro_t,registro_h]:
        cliente.put_record(
            StreamName = 'kinessi_terraform',
            Data = json.dumps(registro),
            PartitionKey = '02'
        )
    time.sleep(10) # Os registros serão criados a cada 10 segundos 