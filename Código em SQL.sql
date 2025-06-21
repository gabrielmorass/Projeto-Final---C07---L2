-- 1. Remover o banco de dados existente e criar novo
DROP DATABASE IF EXISTS projeto;
CREATE DATABASE projeto;
USE projeto;

SET SQL_SAFE_UPDATES = 0;

-- 2. Criação das tabelas
DROP TABLE IF EXISTS Clientes_Sessoes;
DROP TABLE IF EXISTS Ingressos;
DROP TABLE IF EXISTS Vendas;
DROP TABLE IF EXISTS Funcionarios;
DROP TABLE IF EXISTS Sessoes;
DROP TABLE IF EXISTS Salas;
DROP TABLE IF EXISTS Filmes;
DROP TABLE IF EXISTS Clientes;

-- Tabela Clientes
CREATE TABLE Clientes (
    idCliente INT PRIMARY KEY auto_increment,
    nome VARCHAR(50) NOT NULL,
    idade INT,
    email VARCHAR(100)
);

SHOW CREATE TABLE Clientes;
INSERT INTO Clientes (nome, idade, email) VALUES ('Teste', 20, 'teste@email.com');


-- Tabela Filmes
CREATE TABLE Filmes (
    idFilme INT PRIMARY KEY,
    nomeDoFilme VARCHAR(70) NOT NULL,
    duracao INT,
    classificacao VARCHAR(10) NOT NULL
);

-- Tabela Salas
CREATE TABLE Salas (
    idSala INT PRIMARY KEY,
    qtdAssentos INT NOT NULL,
    tipoDeSala VARCHAR(45)
);

-- Tabela Sessões
CREATE TABLE Sessoes (
    idSessao INT PRIMARY KEY,
    data DATE NOT NULL,
    horario TIME NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    idFilme INT NOT NULL,
    idSala INT NOT NULL,
    FOREIGN KEY (idFilme) REFERENCES Filmes(idFilme),
    FOREIGN KEY (idSala) REFERENCES Salas(idSala)
);

-- Tabela de junção Clientes_Sessoes
CREATE TABLE Clientes_Sessoes (
    idCliente INT NOT NULL,
    idSessao INT NOT NULL,
    data_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (idCliente, idSessao),
    FOREIGN KEY (idCliente) REFERENCES Clientes(idCliente),
    FOREIGN KEY (idSessao) REFERENCES Sessoes(idSessao)
);

-- Tabela Ingressos
CREATE TABLE Ingressos (
    idIngresso INT PRIMARY KEY AUTO_INCREMENT,
    assento VARCHAR(10) NOT NULL,
    tipo VARCHAR(45),
    idCliente INT NOT NULL,
    idSessao INT NOT NULL,
    FOREIGN KEY (idCliente) REFERENCES Clientes(idCliente),
    FOREIGN KEY (idSessao) REFERENCES Sessoes(idSessao)
);

-- Tabela Vendas
CREATE TABLE Vendas (
    idVenda INT PRIMARY KEY AUTO_INCREMENT,
    data DATE NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    idCliente INT,
    FOREIGN KEY (idCliente) REFERENCES Clientes(idCliente)
);

-- Tabela Funcionários
CREATE TABLE Funcionarios (
    idFuncionario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(45) NOT NULL,
    cargo VARCHAR(45) NOT NULL,
    salario DECIMAL(10,2),
    idSala INT,
    FOREIGN KEY (idSala) REFERENCES Salas(idSala)
);

-- 3. Inserções de dados
INSERT INTO Filmes VALUES 
(1, 'O Poderoso Chefão', 175, '16'),
(2, 'Interestelar', 169, '12'),
(3, 'Toy Story', 81, 'L');

INSERT INTO Salas VALUES
(1, 120, '3D'),
(2, 80, 'IMAX'),
(3, 150, 'Padrão');

INSERT INTO Clientes (nome, idade, email) VALUES
('Gabriel', 25, 'gabriel@email.com'),
('Henrique', 30, 'henrique@email.com'),
('Livia', 17, 'livia@email.com');


INSERT INTO Sessoes VALUES
(1, '2023-11-20', '19:00:00', 35.00, 1, 1),
(2, '2023-11-20', '16:00:00', 25.00, 2, 2),
(3, '2023-11-21', '14:00:00', 20.00, 3, 3);

INSERT INTO Clientes_Sessoes (idCliente, idSessao) VALUES
(1, 1),
(2, 2),
(3, 3);

INSERT INTO Funcionarios (nome, cargo, salario, idSala) VALUES
('Ana', 'Gerente', 4500.00, 1),
('Pedro', 'Atendente', 2200.00, 2),
('Luiza', 'Operador', 1800.00, 3);

-- 4. Atualizações dos valores
UPDATE Sessoes SET preco = 30.00 WHERE idSessao = 1;
UPDATE Filmes SET classificacao = '14' WHERE idFilme = 2;

UPDATE Salas SET qtdAssentos = 100 WHERE idSala = 1;
UPDATE Salas SET tipoDeSala = 'IMAX 3D' WHERE idSala = 2;

UPDATE Clientes SET email = 'gabriel.novo@email.com' WHERE idCliente = 1;
UPDATE Clientes SET idade = 31 WHERE idCliente = 2;

UPDATE Sessoes SET preco = 40.00 WHERE idSessao = 1;
UPDATE Sessoes SET horario = '19:30:00' WHERE idSessao = 1;

UPDATE Funcionarios SET salario = 4800.00 WHERE idFuncionario = 1;
UPDATE Funcionarios SET cargo = 'Supervisor' WHERE idFuncionario = 2;

-- 5. Exclusões 
DELETE FROM Clientes_Sessoes WHERE idCliente = 3;
DELETE FROM Clientes_Sessoes WHERE idSessao = 2;

DELETE FROM Funcionarios WHERE idFuncionario = 3;
DELETE FROM Funcionarios WHERE salario < 2000.00;

-- 6. SELECTs com JOIN
-- Consulta 1: Clientes com suas sessões e filmes
SELECT c.nome AS cliente, f.nomeDoFilme AS filme, s.data, s.horario
FROM Clientes c
JOIN Clientes_Sessoes cs ON c.idCliente = cs.idCliente
JOIN Sessoes s ON cs.idSessao = s.idSessao
JOIN Filmes f ON s.idFilme = f.idFilme;

-- Consulta 2: Sessões com informações de sala e filme
SELECT f.nomeDoFilme, s.data, s.horario, sa.tipoDeSala AS sala, sa.qtdAssentos
FROM Sessoes s
JOIN Filmes f ON s.idFilme = f.idFilme
JOIN Salas sa ON s.idSala = sa.idSala
WHERE s.data = '2023-11-20';

-- Consulta 3: Funcionários com informações de salas atribuídas
SELECT f.nome AS funcionario, f.cargo, s.tipoDeSala AS sala, s.qtdAssentos
FROM Funcionarios f
JOIN Salas s ON f.idSala = s.idSala
WHERE f.salario > 2000.00;

-- 7. VIEW e PROCEDURE
-- VIEW como o trabalho é sobre um cinema criamos um "VIEW" que as informações relevantes de toda a programção como uma tela de bilheteria em cinemas
DROP VIEW IF EXISTS Programacao_Completa;
CREATE VIEW Programacao_Completa AS
SELECT f.nomeDoFilme, s.data, s.horario, sa.tipoDeSala AS sala, s.preco
FROM Sessoes s
JOIN Filmes f ON s.idFilme = f.idFilme
JOIN Salas sa ON s.idSala = sa.idSala
ORDER BY s.data, s.horario;

-- PROCEDURE foi feito um sistema para automatizar a reserva do cliente com a sessão assim como é feito em aplicativos online para não haver sobreposeções de assentos em reservas  
DROP PROCEDURE IF EXISTS RealizarReserva;
DELIMITER //
CREATE PROCEDURE RealizarReserva(
    IN p_idCliente INT,
    IN p_idSessao INT
)
BEGIN
    DECLARE cliente_existe INT;
    DECLARE sessao_existe INT;
    
    SELECT COUNT(*) INTO cliente_existe FROM Clientes WHERE idCliente = p_idCliente;
    SELECT COUNT(*) INTO sessao_existe FROM Sessoes WHERE idSessao = p_idSessao;
    
    IF cliente_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente não encontrado';
    ELSEIF sessao_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sessão não encontrada';
    ELSE
        INSERT INTO Clientes_Sessoes (idCliente, idSessao) VALUES (p_idCliente, p_idSessao);
        SELECT 'Reserva realizada com sucesso' AS Resultado;
    END IF;
END //
DELIMITER ;

-- Teste da procedure
CALL RealizarReserva(1, 3);