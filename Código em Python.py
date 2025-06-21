import mysql.connector

def conectar():
    return mysql.connector.connect(
    host="localhost",
    user="root",
    password="guga6020",
    database="projeto"
)

if conectar().is_connected():
    print("Bem Vindo ao CineFrost (conexão com o banco de dados)")
else:
    print("🦖Sem Internet (falha na conexão com banco de dados)")

#===========================================================================================================
def comprar_ingresso():
    con = conectar()
    cursor = con.cursor()

    # Coleta dados do cliente
    nome = input("Nome do cliente: ")
    email = input("Email do cliente: ")

    # Verifica se cliente já existe
    cursor.execute("""
        SELECT idCliente FROM Clientes WHERE nome = %s AND email = %s
    """, (nome, email))
    resultado = cursor.fetchone()

    if resultado:
        id_cliente = resultado[0]
        print(f"🔁 Cliente encontrado com ID {id_cliente}.")
    else:
        idade = input("Idade do cliente: ")
        cursor.execute("""
            INSERT INTO Clientes (nome, idade, email)
            VALUES (%s, %s, %s)
        """, (nome, idade, email))
        con.commit()
        id_cliente = cursor.lastrowid
        print(f"✅ Cliente cadastrado com ID {id_cliente}.")

    # Listar sessões disponíveis
    cursor.execute("""
        SELECT s.idSessao, f.nomeDoFilme, s.data, s.horario
        FROM Sessoes s
        JOIN Filmes f ON s.idFilme = f.idFilme
    """)
    sessoes = cursor.fetchall()
    print("\nSessões disponíveis:")
    for sessao in sessoes:
        print(f"ID: {sessao[0]} | Filme: {sessao[1]} | Data: {sessao[2]} | Horário: {sessao[3]}")

    id_sessao = input("Escolha o ID da sessão: ")
    tipo = input("Tipo de ingresso (inteira/meia): ")

    # Verifica se o assento já está ocupado
    while True:
        assento = input("Digite o número do assento desejado: ")

        cursor.execute("""
            SELECT COUNT(*) FROM Ingressos
            WHERE idSessao = %s AND assento = %s
        """, (id_sessao, assento))
        ocupado = cursor.fetchone()[0]

        if ocupado:
            print("❌ Esse assento já está ocupado. Por favor, escolha outro.")
        else:
            break  # assento válido >> sai do loop
    # Realiza a compra
    cursor.execute("""
        INSERT INTO Ingressos (assento, tipo, idCliente, idSessao)
        VALUES (%s, %s, %s, %s)
        """, (assento, tipo, id_cliente, id_sessao))
    con.commit()
    print("🎉 Ingresso comprado com sucesso!")

    cursor.close()
    con.close()
#===========================================================================================================
def trocar_assento():
    con = conectar()
    cursor = con.cursor()

    nome = input("Digite o nome do cliente: ")

    # Buscar ingressos do cliente
    cursor.execute("""
        SELECT i.idIngresso, f.nomeDoFilme, s.data, s.horario, i.assento
        FROM Ingressos i
        JOIN Clientes c ON i.idCliente = c.idCliente
        JOIN Sessoes s ON i.idSessao = s.idSessao
        JOIN Filmes f ON s.idFilme = f.idFilme
        WHERE c.nome = %s
    """, (nome,))
    ingressos = cursor.fetchall()

    if not ingressos:
        print("❌ Nenhum ingresso encontrado para esse cliente.")
        cursor.close()
        con.close()
        return

    # Mostrar opções
    print("\n🎟️ Ingressos encontrados:")
    for ingresso in ingressos:
        print(f"ID Ingresso: {ingresso[0]} | Filme: {ingresso[1]} | Data: {ingresso[2]} | Horário: {ingresso[3]} | Assento atual: {ingresso[4]}")

    id_ingresso = input("\nDigite o ID do ingresso que deseja alterar: ")

    # Buscar idSessao relacionado a esse ingresso
    cursor.execute("""
        SELECT idSessao FROM Ingressos WHERE idIngresso = %s
    """, (id_ingresso,))
    sessao = cursor.fetchone()

    if not sessao:
        print("❌ Ingresso não encontrado.")
        cursor.close()
        con.close()
        return

    id_sessao = sessao[0]

    # Escolher novo assento (com verificação de ocupação)
    while True:
        novo_assento = input("Digite o novo assento: ")
        cursor.execute("""
            SELECT COUNT(*) FROM Ingressos
            WHERE idSessao = %s AND assento = %s
        """, (id_sessao, novo_assento))
        ocupado = cursor.fetchone()[0]

        if ocupado:
            print("⚠️ Esse assento já está ocupado! Tente outro.")
        else:
            break

    # Atualizar assento
    cursor.execute("""
        UPDATE Ingressos SET assento = %s WHERE idIngresso = %s
    """, (novo_assento, id_ingresso))
    con.commit()

    print("✅ Assento atualizado com sucesso!")
    cursor.close()
    con.close()
#===========================================================================================================
def cancelar_ingresso():
    con = conectar()
    cursor = con.cursor()

    nome = input("Digite o nome do cliente: ")

    # Buscar ingressos do cliente
    cursor.execute("""
        SELECT i.idIngresso, f.nomeDoFilme, s.data, s.horario, i.assento
        FROM Ingressos i
        JOIN Clientes c ON i.idCliente = c.idCliente
        JOIN Sessoes s ON i.idSessao = s.idSessao
        JOIN Filmes f ON s.idFilme = f.idFilme
        WHERE c.nome = %s
    """, (nome,))
    ingressos = cursor.fetchall()

    if not ingressos:
        print("❌ Nenhum ingresso encontrado para esse cliente.")
        cursor.close()
        con.close()
        return

    # Mostrar ingressos
    print("\n🎟️ Ingressos encontrados:")
    for ingresso in ingressos:
        print(f"ID Ingresso: {ingresso[0]} | Filme: {ingresso[1]} | Data: {ingresso[2]} | Horário: {ingresso[3]} | Assento: {ingresso[4]}")

    id_ingresso = input("\nDigite o ID do ingresso que deseja reembolsar: ")

    # Verificar se o ingresso realmente pertence ao cliente
    cursor.execute("""
        SELECT COUNT(*) FROM Ingressos i
        JOIN Clientes c ON i.idCliente = c.idCliente
        WHERE i.idIngresso = %s AND c.nome = %s
    """, (id_ingresso, nome))
    pertence = cursor.fetchone()[0]

    if pertence == 0:
        print("❌ Ingresso não pertence a esse cliente ou não existe.")
        cursor.close()
        con.close()
        return

    # Cancelar (deletar) ingresso
    cursor.execute("""
        DELETE FROM Ingressos WHERE idIngresso = %s
    """, (id_ingresso,))
    con.commit()

    print("✅ Ingresso reembolsado com sucesso.\n")
    cursor.close()
    con.close()
#===========================================================================================================
def ver_todos_filmes():
    con = conectar()
    cursor = con.cursor()

    cursor.execute("SELECT * FROM Filmes")
    filmes = cursor.fetchall()

    for f in filmes:
        print(f"ID: {f[0]} | Nome: {f[1]} | Duração: {f[2]} | Classificação: {f[3]}")

    cursor.close()
    con.close()
#===========================================================================================================
def buscar_cliente_por_nome():
    nome = input("Nome do cliente: ")
    con = conectar()
    cursor = con.cursor()

    cursor.execute("SELECT * FROM Clientes WHERE nome = %s", (nome,))
    cliente = cursor.fetchone()

    if cliente:
        print(f"ID: {cliente[0]} | Nome: {cliente[1]} | Idade: {cliente[2]} | Email: {cliente[3]}")
    else:
        print("Cliente não encontrado.")

    cursor.close()
    con.close()
#===========================================================================================================
def menu():
    while True:
        print("\n🎬 Menu do Sistema de Cinema 🎟️")
        print("1. Ver filmes em cartaz")
        print("2. Compra de ingressos")
        print("3. Trocar assento")
        print("4. Pedir reembolso")
        print("5. Buscar perfil")
        print("6. Sair\n")

        escolha = input("Opção:")

        if escolha == '1':
            ver_todos_filmes()
        elif escolha == '2':
            comprar_ingresso()
        elif escolha == '3':
            trocar_assento()
        elif escolha == '4':
            cancelar_ingresso()
        elif escolha == '5':
            buscar_cliente_por_nome()
        elif escolha == '6':
            print("👋 Saindo do sistema. Até logo!")
            break
        else:
            print("❌ Opção inválida. Tente novamente.")

menu()
conectar().close()