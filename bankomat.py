#! python3

import mysql.connector

# łączenie z bazą danych
conn = mysql.connector.connect(
    user="root", password="", host="localhost", database="baza_danych"
)
kursor = conn.cursor()


def stankonta(nr_konta):
    """Sprawdza stan konta"""
    stan_konta = "SELECT saldo FROM konta WHERE nr_konta=%s"
    kursor.execute(stan_konta, (nr_konta,))
    stan_konta = kursor.fetchall()
    return stan_konta[0][0]


while True:
    nr_konta = input("Podaj numer konta: ")

    try:
        stan_konta = stankonta(nr_konta)  # sprawdzanie czy konto instnieje
    except IndexError as e:
        print("Nieprawidłowy numer konta")
    else:
        wybor = int(
            input(
                "\n1. Sprawdzenie stanu konta \
                \n2. Wpłata \
                \n3. Wypłata \
                \n4. Historia transakcji \
                \n\nWybierz opcję (1-4): "
            )
        )

        if wybor == 1:
            #  Wypisanie stanu konta
            print("Twój stan konta wynosi:", str(stan_konta), "zł")

            # Wpis do historii transakcji
            hist = "CALL spr_kon(%s)"
            kursor.execute(hist, (nr_konta,))
            conn.commit()

        elif wybor == 2:
            wplata = int(input("Ile wpłacamy? "))

            #  Wpłata i wpis do historii transakcji
            hist = "CALL wplata(%s, %s)"
            kursor.execute(hist, (nr_konta, wplata))
            conn.commit()

            print("Pomyślnie wpłacono:", wplata, "zł")

        elif wybor == 3:
            wyplata = int(input("Ile wypłacamy? "))

            #  Wypłata i wpis do historii transakcji
            hist = "CALL wyplata(%s, %s)"
            kursor.execute(hist, (nr_konta, wyplata))
            conn.commit()

            if stan_konta >= wyplata:
                print("Pomyślnie wypłacono:", wyplata, "zł")
            else:
                print("Nie można wypłacić. Brak środków na koncie.")

        elif wybor == 4:
            #  Sprawdenie historii transakcji dla danego konta
            #  i wpis do historii transakcji
            hist = "CALL historia_trans(%s)"
            kursor.execute(hist, (nr_konta,))
            myresult = kursor.fetchall()

            print(
                "| Akcja |",
                "ID Konta |",
                "Kwota Transakcji |",
                "Saldo po |",
                "Status |",
            )
            for i in myresult:
                print("%5d %10d %15d %13d %7d" % (i[0], i[1], i[2], i[3], i[4]))
                


kursor.close()
conn.close()
