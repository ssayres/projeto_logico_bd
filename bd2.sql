-- Criando o banco de dados
CREATE DATABASE oficina;
USE oficina;

-- Tabela de Clientes
CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(255) UNIQUE,
    cpf_cnpj VARCHAR(20) UNIQUE NOT NULL
);

-- Tabela de Veículos
CREATE TABLE veiculos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT,
    marca VARCHAR(100) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    ano INT NOT NULL,
    placa VARCHAR(10) UNIQUE NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Tabela de Mecânicos
CREATE TABLE mecanicos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    especialidade VARCHAR(255)
);

-- Tabela de Ordens de Serviço
CREATE TABLE ordens_servico (
    id INT AUTO_INCREMENT PRIMARY KEY,
    veiculo_id INT,
    mecanico_id INT,
    data_entrada DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_saida DATETIME,
    status ENUM('Aberto', 'Em andamento', 'Concluído', 'Cancelado') DEFAULT 'Aberto',
    descricao TEXT,
    valor_total DECIMAL(10,2),
    FOREIGN KEY (veiculo_id) REFERENCES veiculos(id),
    FOREIGN KEY (mecanico_id) REFERENCES mecanicos(id)
);

-- Tabela de Peças e Serviços
CREATE TABLE pecas_servicos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(255) NOT NULL,
    preco DECIMAL(10,2) NOT NULL
);

-- Tabela de Itens da Ordem de Serviço
CREATE TABLE itens_ordem_servico (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ordem_id INT,
    peca_servico_id INT,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (ordem_id) REFERENCES ordens_servico(id),
    FOREIGN KEY (peca_servico_id) REFERENCES pecas_servicos(id)
);

-- Tabela de Pagamentos
CREATE TABLE pagamentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ordem_id INT,
    data_pagamento DATETIME DEFAULT CURRENT_TIMESTAMP,
    metodo_pagamento ENUM('Dinheiro', 'Cartão', 'Pix', 'Boleto') NOT NULL,
    valor_pago DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (ordem_id) REFERENCES ordens_servico(id)
);

-- Queries SQL

-- Recuperações simples com SELECT Statement
SELECT * FROM clientes;
SELECT * FROM veiculos WHERE marca = 'Toyota';

-- Quantidade de ordens de serviço por cliente
SELECT c.nome, COUNT(o.id) AS total_ordens
FROM clientes c
JOIN veiculos v ON c.id = v.cliente_id
JOIN ordens_servico o ON v.id = o.veiculo_id
GROUP BY c.id;

-- Filtrando ordens de serviço em andamento
SELECT * FROM ordens_servico WHERE status = 'Em andamento';

-- Expressões para gerar atributos derivados
SELECT id, data_entrada, data_saida, TIMESTAMPDIFF(DAY, data_entrada, data_saida) AS dias_em_servico
FROM ordens_servico WHERE data_saida IS NOT NULL;

-- Ordenando mecânicos por especialidade
SELECT * FROM mecanicos ORDER BY especialidade;

-- Condições de filtros aos grupos
SELECT mecanico_id, COUNT(*) AS total_ordens
FROM ordens_servico
GROUP BY mecanico_id
HAVING total_ordens > 5;

-- Junção entre tabelas para informações mais complexas
SELECT o.id AS ordem, c.nome AS cliente, v.modelo, m.nome AS mecanico, o.status
FROM ordens_servico o
JOIN veiculos v ON o.veiculo_id = v.id
JOIN clientes c ON v.cliente_id = c.id
JOIN mecanicos m ON o.mecanico_id = m.id;
