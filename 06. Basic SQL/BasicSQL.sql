1. Отобразите все записи из таблицы `company` по компаниям, которые закрылись.

SELECT *
FROM company
WHERE status = 'closed';


2. Отобразите количество привлечённых средств для новостных компаний США. Используйте данные из таблицы `company`. Отсортируйте таблицу по убыванию значений в поле `funding_total`.

SELECT funding_total
FROM company
WHERE category_code = 'news' AND country_code = 'USA'
ORDER BY funding_total DESC;


3. Найдите общую сумму сделок по покупке одних компаний другими в долларах. Отберите сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно.

SELECT SUM(price_amount)
FROM acquisition
WHERE term_code = 'cash' AND EXTRACT(YEAR FROM CAST(acquired_at AS date)) BETWEEN '2011' AND '2013';


4. Отобразите имя, фамилию и названия аккаунтов людей в поле `network_username`, у которых названия аккаунтов начинаются на 'Silver'.

SELECT first_name,
       last_name,
       twitter_username
FROM people
WHERE twitter_username LIKE 'Silver%';


5. Выведите на экран всю информацию о людях, у которых названия аккаунтов в поле `network_username` содержат подстроку 'money', а фамилия начинается на 'K'.

SELECT *
FROM people
WHERE twitter_username LIKE '%money%' AND last_name LIKE 'K%';


6. Для каждой страны отобразите общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране. Страну, в которой зарегистрирована компания, можно определить по коду страны. Отсортируйте данные по убыванию суммы.

SELECT country_code,
       SUM(funding_total)
FROM company
GROUP BY country_code
ORDER BY SUM(funding_total) DESC;


7. Составьте таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату.
Оставьте в итоговой таблице только те записи, в которых минимальное значение суммы инвестиций не равно нулю и не равно максимальному значению.

SELECT funded_at, 
       MIN(raised_amount),
       MAX(raised_amount)
FROM funding_round
GROUP BY funded_at
HAVING MIN(raised_amount) != 0 AND MIN(raised_amount) != MAX(raised_amount);


8. Создайте поле с категориями:
		Для фондов, которые инвестируют в 100 и более компаний, назначьте категорию high_activity.
		Для фондов, которые инвестируют в 20 и более компаний до 100, назначьте категорию middle_activity.
		Если количество инвестируемых компаний фонда не достигает 20, назначьте категорию low_activity.
Отобразите все поля таблицы `fund` и новое поле с категориями.

SELECT
 CASE
   WHEN invested_companies >= 100 THEN 'high_activity'
   WHEN invested_companies >= 20 AND invested_companies <= 100      THEN 'middle_activity'
   ELSE 'low_activity'
 END, *
FROM fund;


9. Для каждой из категорий, назначенных в предыдущем задании, посчитайте округлённое до ближайшего целого числа среднее количество инвестиционных раундов, в которых фонд принимал участие. Выведите на экран категории и среднее число инвестиционных раундов. Отсортируйте таблицу по возрастанию среднего.

SELECT ROUND(AVG(investment_rounds)) avg_round,
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity
FROM fund
GROUP BY activity
ORDER BY avg_round;


10. Проанализируйте, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы. 
Для каждой страны посчитайте минимальное, максимальное и среднее число компаний, в которые инвестировали фонды этой страны, основанные с 2010 по 2012 год включительно. Исключите страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю. 
Выгрузите десять самых активных стран-инвесторов: отсортируйте таблицу по среднему количеству компаний от большего к меньшему. Затем добавьте сортировку по коду страны в лексикографическом порядке.

SELECT country_code,
       MIN(invested_companies),
       MAX(invested_companies),
       AVG(invested_companies)
FROM fund
WHERE EXTRACT(YEAR FROM CAST(founded_at AS date)) BETWEEN '2010' AND '2012'
GROUP BY country_code
HAVING MIN(invested_companies) != 0
ORDER BY AVG(invested_companies) DESC, country_code
LIMIT 10;


11. Отобразите имя и фамилию всех сотрудников стартапов. Добавьте поле с названием учебного заведения, которое окончил сотрудник, если эта информация известна.

SELECT p.first_name,
       p.last_name,
       e.instituition
FROM people p
LEFT JOIN education e ON p.id = e.person_id;


12. Для каждой компании найдите количество учебных заведений, которые окончили её сотрудники. Выведите название компании и число уникальных названий учебных заведений. Составьте топ-5 компаний по количеству университетов.

SELECT c.name,
       COUNT(DISTINCT instituition)
FROM company c
JOIN people p ON p.company_id = c.id
JOIN education e ON p.id = e.person_id
GROUP BY c.name
ORDER BY COUNT(DISTINCT instituition) DESC
LIMIT 5;


13. Составьте список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним.

SELECT DISTINCT c.name
FROM company c
LEFT JOIN funding_round fr ON c.id = fr.company_id
WHERE c.status = 'closed'
AND is_first_round = 1 AND is_last_round = 1;


14. Составьте список уникальных номеров сотрудников, которые работают в компаниях, отобранных в предыдущем задании.

WITH
     u AS (
     SELECT DISTINCT c.name, c.id
     FROM company c
     LEFT JOIN funding_round fr ON c.id = fr.company_id
     WHERE c.status = 'closed'
     AND is_first_round = 1 AND is_last_round = 1)

SELECT DISTINCT p.id
FROM people p
WHERE p.company_id IN (SELECT id FROM u);


15. Составьте таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, которое окончил сотрудник.

WITH
     u AS (
     SELECT DISTINCT c.name, c.id
     FROM company c
     LEFT JOIN funding_round fr ON c.id = fr.company_id
     WHERE c.status = 'closed'
     AND is_first_round = 1 AND is_last_round = 1)

SELECT DISTINCT p.id, e.instituition
FROM people p
JOIN education e ON e.person_id = p.id
WHERE p.company_id IN (SELECT id FROM u);


16. Посчитайте количество учебных заведений для каждого сотрудника из предыдущего задания. При подсчёте учитывайте, что некоторые сотрудники могли окончить одно и то же заведение дважды.

WITH
     u AS (
     SELECT DISTINCT c.name, c.id
     FROM company c
     LEFT JOIN funding_round fr ON c.id = fr.company_id
     WHERE c.status = 'closed'
     AND is_first_round = 1 AND is_last_round = 1)

SELECT DISTINCT p.id, COUNT(e.instituition)
FROM people p
JOIN education e ON e.person_id = p.id
WHERE p.company_id IN (SELECT id FROM u)
GROUP BY p.id;


17. Дополните предыдущий запрос и выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники разных компаний. Нужно вывести только одну запись, группировка здесь не понадобится.

WITH
     s AS (
     WITH
          u AS (SELECT DISTINCT c.name, c.id
          FROM company c
          LEFT JOIN funding_round fr ON c.id = fr.company_id
          WHERE c.status = 'closed'
          AND is_first_round = 1 AND is_last_round = 1)

     SELECT DISTINCT p.id, COUNT(e.instituition) count_instituition
     FROM people p
     JOIN education e ON e.person_id = p.id
     WHERE p.company_id IN (SELECT id FROM u)
     GROUP BY p.id)

SELECT AVG(s.count_instituition)
FROM s;


18. Напишите похожий запрос: выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники Socialnet.

WITH
     s AS (
     WITH
          u AS (
          SELECT DISTINCT c.name, c.id
          FROM company c
          LEFT JOIN funding_round fr ON c.id = fr.company_id
          WHERE c.name = 'Facebook' )

     SELECT DISTINCT p.id, COUNT(e.instituition) count_instituition
     FROM people p
     JOIN education e ON e.person_id = p.id
     WHERE p.company_id IN (SELECT id FROM u) 
     GROUP BY p.id)

SELECT AVG(s.count_instituition)
FROM s;


19. Составьте таблицу из полей:
		name_of_fund — название фонда;
		name_of_company — название компании;
		amount — сумма инвестиций, которую привлекла компания в раунде.
В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов, а раунды финансирования проходили с 2012 по 2013 год включительно.

WITH
     s AS (
     SELECT name name_of_company, id
     FROM company
     WHERE milestones > 6),

     d AS(
     SELECT raised_amount amount, id
     FROM funding_round
     WHERE EXTRACT(YEAR FROM CAST(funded_at AS date)) BETWEEN '2012' AND '2013')

SELECT f.name name_of_fund,
       s.name_of_company,
       d.amount
FROM investment i
JOIN s ON s.id = i.company_id
JOIN fund f ON i.fund_id = f.id
JOIN d ON d.id = i.funding_round_id;


20. Выгрузите таблицу, в которой будут такие поля:
		название компании-покупателя;
		сумма сделки;
		название компании, которую купили;
		сумма инвестиций, вложенных в купленную компанию;
		доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, округлённая до ближайшего целого числа.
Не учитывайте те сделки, в которых сумма покупки равна нулю. Если сумма инвестиций в компанию равна нулю, исключите такую компанию из таблицы. 

SELECT acquiring.name acquiring_company,
       a.price_amount price_amount,
       acquired.name acquired_company,
       acquired.funding_total funding_total,
       ROUND(a.price_amount/acquired.funding_total)
FROM acquisition a
LEFT JOIN company acquiring ON a.acquiring_company_id = acquiring.id 
LEFT JOIN company acquired ON a.acquired_company_id = acquired.id
WHERE a.price_amount > 0 AND acquired.funding_total != 0
ORDER BY price_amount DESC, acquired_company
LIMIT 10;


21. Выгрузите таблицу, в которую войдут названия компаний из категории social, получившие финансирование с 2010 по 2013 год включительно. Проверьте, что сумма инвестиций не равна нулю. Выведите также номер месяца, в котором проходил раунд финансирования.

SELECT c.name,
       EXTRACT(MONTH FROM CAST(fr.funded_at AS DATE))
FROM company c
JOIN funding_round fr ON c.id = fr.company_id
WHERE c.category_code = 'social' AND fr.raised_amount > 0 AND EXTRACT(YEAR FROM CAST(fr.funded_at AS DATE)) BETWEEN '2010' AND '2013’;


22. Отберите данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. Сгруппируйте данные по номеру месяца и получите таблицу, в которой будут поля:
		номер месяца, в котором проходили раунды;
		количество уникальных названий фондов из США, которые инвестировали в этом месяце;
		количество компаний, купленных за этот месяц;
		общая сумма сделок по покупкам в этом месяце.
		
WITH
     name_fund AS (
     SELECT COUNT(DISTINCT f.name) count_name_fund, 
            EXTRACT(MONTH FROM CAST(fr.funded_at AS DATE)) months
     FROM fund f
     JOIN investment i ON f.id = i.fund_id
     JOIN funding_round fr ON fr.id = i.funding_round_id
     WHERE country_code = 'USA' AND EXTRACT(YEAR FROM CAST(fr.funded_at AS DATE)) BETWEEN '2010' AND '2013'
     GROUP BY months),
 
     acquisition AS (
     SELECT COUNT(acquired_company_id) count_acquired_company, 
            SUM(price_amount) price_amount, 
            EXTRACT(MONTH FROM CAST(acquired_at AS DATE)) months
     FROM acquisition
     WHERE EXTRACT(YEAR FROM CAST(acquired_at AS DATE)) BETWEEN '2010' AND '2013'
     GROUP BY months) 

SELECT name_fund.months,
       name_fund.count_name_fund,
       acquisition.count_acquired_company,
       acquisition.price_amount
FROM name_fund JOIN acquisition ON acquisition.months = name_fund.months;


23. Составьте сводную таблицу и выведите среднюю сумму инвестиций для стран, в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах. Данные за каждый год должны быть в отдельном поле. Отсортируйте таблицу по среднему значению инвестиций за 2011 год от большего к меньшему.

WITH
     inv_2011 AS (
     SELECT country_code, 
            AVG(funding_total) avg_total_11
     FROM company
     WHERE EXTRACT(YEAR FROM CAST(founded_at AS DATE)) = '2011'
     GROUP BY country_code), 

     inv_2012 AS (
     SELECT country_code, 
            AVG(funding_total) avg_total_12
     FROM company
     WHERE EXTRACT(YEAR FROM CAST(founded_at AS DATE)) = '2012'
     GROUP BY country_code),
     
     inv_2013 AS (
     SELECT country_code, 
            AVG(funding_total) avg_total_13
     FROM company
     WHERE EXTRACT(YEAR FROM CAST(founded_at AS DATE)) = '2013'
     GROUP BY country_code)
     
SELECT inv_2011.country_code,
       inv_2011.avg_total_11,
       inv_2012.avg_total_12,
       inv_2013.avg_total_13
FROM  inv_2011
INNER JOIN inv_2012 ON inv_2012.country_code = inv_2011.country_code-- присоедините таблицы
INNER JOIN inv_2013 ON inv_2013.country_code = inv_2011.country_code
ORDER BY inv_2011.avg_total_11 DESC;

