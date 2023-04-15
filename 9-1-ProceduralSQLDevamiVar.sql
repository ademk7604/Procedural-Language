-- *********** DEgisken Tanimlama **********
do $$ -- anonymous block , dolar isaretii ozel karakterler oncesinde tirnak isaretini kullanmamak icin
declare
	counter integer := 1; --counter isminde degisken olusturuldu ve default degeri verildi.
	first_name varchar(50) := 'Ahmet';
	last_name varchar(50) := 'Gok';
	payment numeric(4,2) := 20.5 ; --20.50 ddiye DBye kaydeder. numeric(precision, scale) -> precision : 1 den 38 e kadar deger girilebiliyor
begin
	raise notice '% % % has been paid % USD', 
		counter,
		first_name,
		last_name,
		payment;
end $$ ;

-- TAsk 1 : degiskenler olusturarak ekrana Ahmet ve Mehmet beytler 120 tl ye bilet aldilar.
--cumlesini ekrana basiniz
do $$
declare
	first_person varchar(50) := 'Ahmet';
	second_person varchar(50) := 'Mehmet';
	payment numeric(3) := 120;
begin
	raise notice '% ve % Beyler % TL ye bilet aldilar',
	first_person,
	second_person,
	payment;
end $$;

-- ************* Bekletme Komudu ***************
do $$
declare -- declare kismi option dir. degisken olusturulmayacaksa yazmaya gerek yok begin ve end zorunlu tabi
	create_at time := now(); --atama yapildi
begin
	raise notice '%', create_at; --create_at i al yertutucuya ata
	perform pg_sleep(5); -- 5 saniye bekle
	raise notice '%', create_at; --ayni degeri gorecegiz, yukaridan asagiya normal calisiyor
end $$;

-- ************** Tablodan Data Tipini Kopyalama ***************
do $$
declare
	film_title film.title%type; -- film_title text; yapsaydi manule olurdu db de daha sonra degistimizde patlar bursi
	--featured_title film.title%type; ihtiyac olmadi asagida kullanmadik 
begin
	-- 1 id li filmin ismini getirelim --
	select title
	from film
	into film_title -- flm_title : = 'Kuzularin Sessizligi' type da yukarida belirleyerek boyle atadik.
	where id=1;
	
	raise notice 'Film title with id 1 : %', film_title;
end $$;

-- ****************** ROW TYPE **********************
do $$
declare
	selected_actor actor%rowtype;
begin
	-- id si 1 olan actoru getir
	select *
	from actor
	into selected_actor
	where id =1;
	
	raise notice 'The actor name is : % %',
		selected_actor.first_name,
		selected_actor.last_name;   
end $$ ; --The actor name is : Cuneyt Arkin

-- ****************Recor Type******* bazi datalarini almak istiyorsak bu yapiyi k.***
do $$
declare
	rec record; --record d.type olan rec nesnesine atama yapacagiz asagida
begin
	-- filmi seciyoruz
	select id, title, type
	into rec
	from film
	where id=2;
	
	raise notice '% % %', rec.id, rec.title, rec.type;
end $$; --2 Esaretin Bedeli Macera

-- ********* IC ICE BLOK *************
-- suanlik db ile isimiz yok ogrenmek icin ornek
do $$
<<outer_blok>> -- optional der yazmak zorunda degiliz burayi
declare -- outher blok dis blok
	counter integer := 0;
begin
	counter := counter +1;
	raise notice 'counter degerim : %', counter;
	
	declare --inner blok burdan girdik
		counter integer :=0;
	begin
		counter := counter +10 ;
		raise notice 'ic blokdaki counter degerim : % ', counter;
		raise notice 'dis blokdaki counter degerim : % ', outer_blok.counter;

	end; -- ic blok burda bitti
	-- suan dis blok icinde islem yapabilirim
	raise notice 'dis blokdaki counter degerim : %', counter; 
	--burda artik outer_blok kullanamya gerek yok scope den dolayi disi verir zaten

end $$ ;

-- ****************Contant************
-- selling_price := net_price * 0.1 ; bu gibi hard kodlardan kurtul
-- selling_price := net_price + net_price * vat ; boyle dianmik kod yazmak lazim
do $$
declare
	vat constant numeric := 0.1;
	net_price numeric := 20.5;
begin
 	raise notice 'Satis fiyati : %', net_price*(1+vat);
	-- vat := 0.05; constant(sabit) bir ifadeyi degistirmeye calsiirsak hata aliriz
end $$; --Satis fiyati : 22.55

-- constant bir ifadeye RunTime de deger verebilirmiyim?
do $$
declare
	start_at constant time := now(); -- bu sekilde islemin yapildigi saati c. ile sabitlerim kimse degistiremez
begin
	raise notice 'blogun calisma zmani : %', start_at;
end $$ ;


-- /////////// Control Strucrures ///////

-- ************ if Statement *****************
if condition then --condition sart durum
	statement;
end if;

-- Task : o id li filmi bulalim eger yoksa ekrana uyari yazisi verelim
do $$
declare
	selected_film film%rowtype;
	input_film_id film.id%type :=0; -- film in id sinin d.t atadim ve 0 olarak belirledim
begin
	select * from film
	into selected_film
	where id = input_film_id;
	
	if not found then -- verdigim 0 id sinin yerine olan 1 i verdigimde burasi calismiyor
		raise notice 'Girdiginiz id li film bulunamadi : %', input_film_id;
	end if;
end $$; -- Girdiginiz id li film bulunamadi : 0 -- varsa da bos veriyor onuda asagida else kismi ile yapacagiz
-- ***** IF-THEN-ELSE **
/* Su sekidle calisir
		if condision then
			statements;
		else
			alternative-statements;
		END if;
		
*/

do $$
declare
	selected_film film%rowtype; -- 
	input_film_id film.id%type := 3;	--3 id filmi getir selected_filme ata diyorum 
begin
	select * from film
	into selected_film
	where id= input_film_id;
	
	if not  found then
		raise notice 'Girmis oldugunuz id li  film bulunamadi : % ', input_film_id;
	else
		raise notice 'Filmin ismi : %', selected_film.title;
	end if;
end $$; -- Filmin ismi : Kisa Film -- veya Girmis oldugunuz id li  film bulunamadi : 6 

-- ************ IF-THEN_ELSE_IF ************** elinden geldigince bu derin sorgulamalara girmeyelim
-- syntax :
if condition_1 then
		statement_1;
		
	elsif condition_2 then
		statement_2;
		...
	elsif condition_n then
		statement_n;
		
	else
		else-statement;
	end if;
-- yapi busekilde
-- Task : 1 id li film varsa ;
	suresi 50 dakikanin altinda ise Short,
	50<length>120 ise Medium,
	length>120 ise Long yazalim

do $$
declare
	selected_film film%rowtype; -- 
	input_film_id film.id%type := 3;	--3 id filmi getir selected_filme ata diyorum 
begin
	select * from film
	into selected_film
	where id= input_film_id.length<50;

if condition_1 then
		statement_1;
		
	elsif condition_2 then
		statement_2;
		...
	elsif condition_n then
		statement_n;
		
	else
		else-statement;
	end if;










	