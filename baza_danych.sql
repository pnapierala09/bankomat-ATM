-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Czas generowania: 27 Lis 2023, 12:54
-- Wersja serwera: 10.4.24-MariaDB
-- Wersja PHP: 8.1.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Baza danych: `baza2`
--

DELIMITER $$
--
-- Procedury
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `historia_trans` (IN `NK` INT)   BEGIN

	SELECT H.id_akcji, H.id_konta, H.kwota_transakcji, H.saldo_po, H.id_statusu FROM historia_transakcji H, konta K WHERE K.nr_konta=NK AND H.id_konta=K.id ORDER BY H.id DESC LIMIT 5; 

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `spr_kon` (IN `NK` INT)   BEGIN

    DECLARE sal INT; -- saldo
    DECLARE idkon INT;  -- id_konta
    DECLARE kursor CURSOR FOR SELECT saldo FROM konta WHERE nr_konta=NK;
    DECLARE kursor2 CURSOR FOR SELECT id FROM konta WHERE nr_konta=NK;
    
    OPEN kursor;
    FETCH kursor INTO sal;
    
    OPEN kursor2;
    FETCH kursor2 INTO idkon;
    
    INSERT INTO historia_transakcji(id_akcji, id_kanalu, id_konta, id_statusu, kwota_transakcji, saldo_po)
    VALUES (1, 1, idkon, 1, 0, sal);
    -- (sprawdzenie_salda, bankomat, idkon, wykonano, 0, sal)

    CLOSE kursor; 
    CLOSE kursor2;
 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `wplata` (IN `NK` INT, IN `KWOTA` INT)   BEGIN

    DECLARE sal INT; -- saldo
    DECLARE idkon INT;  -- id_konta
    DECLARE kursor CURSOR FOR SELECT saldo FROM konta WHERE nr_konta=NK;
    DECLARE kursor2 CURSOR FOR SELECT id FROM konta WHERE nr_konta=NK;
        
    OPEN kursor;
    FETCH kursor INTO sal;
    
    OPEN kursor2;
    FETCH kursor2 INTO idkon;
		
    START TRANSACTION;
        
        UPDATE konta 
        SET saldo = (saldo + KWOTA)
        WHERE nr_konta=NK;
         	
        INSERT INTO historia_transakcji(id_akcji, id_kanalu, id_konta, id_statusu, kwota_transakcji, saldo_po)
    	VALUES (2, 1, idkon, 1, KWOTA, (sal+KWOTA));
   		-- (wpłata, bankomat, idkon, wykonano, KWOTA, sal)
        
	COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `wyplata` (IN `NK` INT, IN `KWOTA` INT)   BEGIN 
    
    	DECLARE sal INT; -- saldo
	    DECLARE idkon INT;  -- id_konta
	    DECLARE kursor CURSOR FOR SELECT saldo FROM konta WHERE nr_konta=NK;
	    DECLARE kursor2 CURSOR FOR SELECT id FROM konta WHERE nr_konta=NK;
        
        OPEN kursor;
        FETCH kursor INTO sal;
        
        OPEN kursor2;
    	FETCH kursor2 INTO idkon;
       
    START TRANSACTION;
    
    	IF sal >= KWOTA THEN
        	UPDATE konta 
            SET saldo = (saldo - KWOTA)
            WHERE nr_konta=NK;
         	
            INSERT INTO historia_transakcji(id_akcji, id_kanalu, id_konta, id_statusu, kwota_transakcji, saldo_po)
    		VALUES (3, 1, idkon, 1, -(KWOTA), (sal-KWOTA));
    		-- (wypłata, bankomat, idkon, wykonano, KWOTA, sal)
            
        ELSE
            INSERT INTO historia_transakcji(id_akcji, id_kanalu, id_konta, id_statusu, kwota_transakcji, saldo_po)
    		VALUES (3, 1, idkon, 2, -(KWOTA), sal);
    		-- (wypłata, bankomat, idkon, wykonano, KWOTA, sal)
        END IF;
        
    COMMIT;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `akcje`
--

CREATE TABLE `akcje` (
  `id` int(11) NOT NULL,
  `nazwa` varchar(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Zrzut danych tabeli `akcje`
--

INSERT INTO `akcje` (`id`, `nazwa`) VALUES
(1, 'sprawdzenie_salda'),
(2, 'wpłata'),
(3, 'wypłata');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `historia_transakcji`
--

CREATE TABLE `historia_transakcji` (
  `id` int(11) NOT NULL,
  `id_akcji` int(11) NOT NULL,
  `id_konta` int(11) NOT NULL,
  `id_kanalu` int(11) NOT NULL,
  `kwota_transakcji` int(11) NOT NULL,
  `saldo_po` int(11) NOT NULL,
  `id_statusu` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Zrzut danych tabeli `historia_transakcji`
--

INSERT INTO `historia_transakcji` (`id`, `id_akcji`, `id_konta`, `id_kanalu`, `kwota_transakcji`, `saldo_po`, `id_statusu`) VALUES
(4, 1, 1, 1, 0, 2354, 1),
(12, 1, 3, 1, 0, 36743, 1),
(13, 1, 1, 1, 0, 2354, 1),
(14, 1, 4, 1, 0, 267321, 1),
(15, 2, 1, 1, 100, 2354, 1),
(16, 2, 1, 1, -200, 2454, 1),
(17, 2, 1, 1, 100, 2254, 1),
(18, 1, 1, 1, 0, 2354, 1),
(19, 2, 3, 1, 500, 37043, 1),
(20, 3, 4, 1, 100, 267321, 1),
(21, 3, 2, 1, 100, 34673, 1),
(22, 3, 2, 1, 100, 34573, 1),
(23, 1, 1, 1, 0, 2354, 1),
(24, 1, 1, 1, 0, 2354, 1),
(25, 3, 1, 1, 24533647, 2354, 2),
(26, 1, 1, 1, 0, 2354, 1),
(27, 2, 3, 1, 300, 37543, 1),
(28, 1, 1, 1, 0, 2354, 1),
(29, 1, 1, 1, 0, 2354, 1),
(30, 1, 1, 1, 0, 2354, 1),
(31, 2, 1, 1, 200, 2354, 1),
(32, 3, 1, 1, 300, 2554, 1),
(33, 3, 1, 1, 10000, 2254, 2),
(34, 3, 1, 1, 300, 2254, 1),
(35, 3, 1, 1, -300, 1954, 1),
(36, 2, 1, 1, 200, 1854, 1),
(37, 1, 1, 1, 0, 1854, 1),
(38, 2, 1, 1, 200, 2054, 1),
(39, 1, 1, 1, 0, 2054, 1),
(40, 1, 1, 1, 0, 2054, 1),
(41, 1, 1, 1, 0, 2054, 1),
(42, 1, 1, 1, 0, 2054, 1),
(43, 1, 1, 1, 0, 2054, 1),
(44, 2, 1, 1, 200, 2254, 1),
(45, 1, 1, 1, 0, 2254, 1),
(46, 3, 1, 1, -300, 1954, 1),
(47, 3, 1, 1, -30000, -28046, 2),
(48, 1, 1, 1, 0, 1954, 1),
(49, 2, 1, 1, 200, 2154, 1),
(50, 3, 1, 1, -300, 1854, 1),
(51, 3, 1, 1, -30000, 1854, 2),
(55, 1, 3, 1, 0, 37843, 1),
(56, 2, 1, 1, 200, 2054, 1),
(57, 3, 3, 1, -300, 37543, 1),
(58, 2, 1, 1, 300, 2354, 1),
(59, 3, 3, 1, -400, 37143, 1),
(60, 2, 1, 1, 400, 2754, 1),
(61, 3, 4, 1, -300000, 267221, 2),
(62, 3, 1, 1, -30000, 2754, 2),
(63, 3, 4, 1, -200, 267021, 1),
(64, 3, 3, 1, -400, 36743, 1),
(65, 2, 1, 1, 400, 3154, 1),
(66, 1, 1, 1, 0, 3154, 1),
(67, 2, 1, 1, 400, 3554, 1),
(68, 3, 1, 1, -50, 3504, 1),
(69, 3, 1, 1, -40000, 3504, 2),
(70, 1, 1, 1, 0, 3504, 1),
(71, 1, 1, 1, 0, 3504, 1),
(72, 2, 1, 1, 123, 3627, 1),
(73, 3, 1, 1, -300, 3327, 1);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `kanaly_transakcji`
--

CREATE TABLE `kanaly_transakcji` (
  `id` int(11) NOT NULL,
  `nazwa` varchar(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Zrzut danych tabeli `kanaly_transakcji`
--

INSERT INTO `kanaly_transakcji` (`id`, `nazwa`) VALUES
(1, 'bankomat');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `konta`
--

CREATE TABLE `konta` (
  `id` int(11) NOT NULL,
  `nr_konta` int(26) NOT NULL,
  `id_osoby` int(11) NOT NULL,
  `saldo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Zrzut danych tabeli `konta`
--

INSERT INTO `konta` (`id`, `nr_konta`, `id_osoby`, `saldo`) VALUES
(1, 12345, 1, 3327),
(2, 67890, 2, 34473),
(3, 23456, 3, 36743),
(4, 34567, 2, 267021);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `osoby`
--

CREATE TABLE `osoby` (
  `id` int(11) NOT NULL,
  `imie` varchar(32) NOT NULL,
  `nazwisko` varchar(32) NOT NULL,
  `PESEL` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Zrzut danych tabeli `osoby`
--

INSERT INTO `osoby` (`id`, `imie`, `nazwisko`, `PESEL`) VALUES
(1, 'Anna', 'Woźniak', 12345),
(2, 'Krzysztof', 'Baran', 36368),
(3, 'Andrzej', 'Michalak', 53253),
(4, 'Katarzyna', 'Zielińska', 53686),
(5, 'Maria', 'Lewandowska', 34325),
(6, 'Małgorzata', 'Szymańska', 35238),
(7, 'Tomasz', 'Szewczyk', 97978),
(8, 'Agnieszka', 'Dąbrowska', 23589),
(9, 'Paweł', 'Ostrowski', 12424),
(10, 'Piotr', 'Walczak', 89797);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `statusy`
--

CREATE TABLE `statusy` (
  `id` int(11) NOT NULL,
  `nazwa` varchar(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Zrzut danych tabeli `statusy`
--

INSERT INTO `statusy` (`id`, `nazwa`) VALUES
(1, 'Wykonano'),
(2, 'Anulowano');

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `akcje`
--
ALTER TABLE `akcje`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `historia_transakcji`
--
ALTER TABLE `historia_transakcji`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_akcji` (`id_akcji`),
  ADD KEY `id_kanalu` (`id_kanalu`),
  ADD KEY `id_konta` (`id_konta`),
  ADD KEY `id_statusu` (`id_statusu`);

--
-- Indeksy dla tabeli `kanaly_transakcji`
--
ALTER TABLE `kanaly_transakcji`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `konta`
--
ALTER TABLE `konta`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_osoby` (`id_osoby`);

--
-- Indeksy dla tabeli `osoby`
--
ALTER TABLE `osoby`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `statusy`
--
ALTER TABLE `statusy`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT dla zrzuconych tabel
--

--
-- AUTO_INCREMENT dla tabeli `akcje`
--
ALTER TABLE `akcje`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT dla tabeli `historia_transakcji`
--
ALTER TABLE `historia_transakcji`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=74;

--
-- AUTO_INCREMENT dla tabeli `kanaly_transakcji`
--
ALTER TABLE `kanaly_transakcji`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT dla tabeli `konta`
--
ALTER TABLE `konta`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT dla tabeli `osoby`
--
ALTER TABLE `osoby`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT dla tabeli `statusy`
--
ALTER TABLE `statusy`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Ograniczenia dla zrzutów tabel
--

--
-- Ograniczenia dla tabeli `historia_transakcji`
--
ALTER TABLE `historia_transakcji`
  ADD CONSTRAINT `historia_transakcji_ibfk_1` FOREIGN KEY (`id_akcji`) REFERENCES `akcje` (`id`),
  ADD CONSTRAINT `historia_transakcji_ibfk_2` FOREIGN KEY (`id_kanalu`) REFERENCES `kanaly_transakcji` (`id`),
  ADD CONSTRAINT `historia_transakcji_ibfk_3` FOREIGN KEY (`id_konta`) REFERENCES `konta` (`id`),
  ADD CONSTRAINT `historia_transakcji_ibfk_4` FOREIGN KEY (`id_statusu`) REFERENCES `statusy` (`id`);

--
-- Ograniczenia dla tabeli `konta`
--
ALTER TABLE `konta`
  ADD CONSTRAINT `konta_ibfk_1` FOREIGN KEY (`id_osoby`) REFERENCES `osoby` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
