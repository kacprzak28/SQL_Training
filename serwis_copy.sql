
WITH qwerty AS
(

select 
c.NrZlec,
knt.knt_Akronim as 'Knt_Akronim',  -- tabela kontrahenci akronim
knt.Knt_Nazwa1 as 'Knt_Nazwa', -- tabela kontrahenci nazwa
c.SZN_Rok, 
c.SZN_Miesiac,
c.Rodzaj,
c.Typ,
--c.Czynnosc,
c.Skladnik,
c.skladnikkod,
--c.Urzadzenie as Urzadzenie,
isnull(urz.SUP_ParWartoscS,'<nieznany>')as 'NrSeryjny', 
sum(c.Przychod) as 'przychod',
sum(c.Koszt) as 'koszt',
c.SZN_Id,
c.CzasWykonania ,
c.CzasRealizacji,
c.CzynnoscNumer,
c.StatusCzynnosc,
sum(IloscCzynnosci) as IloscCzynnosci,
CDN.Atrybuty.Atr_Wartosc as 'MPK_ZSR',
case 
when A1.Atr_Wartosc is null then A2.Atr_Wartosc
when A2.Atr_Wartosc is null then A1.Atr_Wartosc 
else '-' end as 'Cecha transakcji2',

isnull(nagl.SZN_Opis,'<nieznany>') as 'Opis',
isnull(nagl.SZN_CechaOpis,'<nieznany>') as ' Cecha transakcji',
isnull(urz.SUR_Kod,'<nieznany>') as 'Rodzaj urządzenia',
isnull(urz.SrU_Nazwa,'<nieznany>') as 'Nazwa urządzenia',
trn.TrN_DokumentObcy as 'Dokument powiązany',
CASE nagl.SZN_Stan 
WHEN 1 THEN 'W buforze'
WHEN 2 THEN 'W buforze'
WHEN 3 THEN 'Do realizacji'
WHEN 4 THEN 'Zatwierdzone'
WHEN 5 THEN 'W realizacji'
WHEN 6 THEN 'Zamknięte'
WHEN 7 THEN 'Anulowane'
ELSE 'Odrzucone'
END as 'Stan zlecenia',
op.Ope_Ident as 'Operator'

--A1.Atr_Wartosc,
--A2.Atr_Wartosc,

from (


		select
	tog.NrZlec,
	tog.SZN_Rok, 
tog.SZN_Miesiac,
	tog.Rodzaj
	,tog.Typ
	,tog.Czynnosc
	,tog.Skladnik
	, tog.skladnikkod
	,urz2.SrU_Nazwa as Urzadzenie
	,tog.Przychod
	,CASE WHEN (tog.Typ = 'C' Or tog.Typ = 'K') THEN tog.Koszt*tog.Ilosc
	WHEN (tog.Typ = 'S') THEN tog.Koszt ELSE
	isnull(convert(decimal(15,2),ceny.wartosc),0)*tog.Ilosc end as Koszt
	,tog.SZN_Id
	,tog.CzasWykonania 
	,tog.CzasRealizacji
	,tog.CzynnoscNumer
	,sl.SLW_WartoscS as StatusCzynnosc
	,tog.IloscCzynnosci as IloscCzynnosci
	

	
	from (

	
--CZYNNOSCI
--czynno?�ć sprzeda??

select 
case 
when nag.SZN_Miesiac<9 then CONCAT('ZSR-', nag.SZN_Numer, '/', RIGHT(nag.SZN_Rok, 2), '/', '0', nag.SZN_Miesiac, '/', nag.SZN_Seria)
else CONCAT('ZSR-', nag.SZN_Numer, '/', RIGHT(nag.SZN_Rok, 2), '/', nag.SZN_Miesiac, '/', nag.SZN_Seria) end AS NrZlec,
nag.SZN_Rok, 
nag.SZN_Miesiac,
'Sprzedaz' AS Rodzaj,
'C' as Typ,
czyn.SZC_TwrNazwa as Czynnosc,
czyn.SZC_TwrNazwa as Skladnik,
twr_kod as skladnikkod,
czyn.SZC_WartoscPoRabacie  as Przychod,
czyn.SZC_CenaZakupu as Koszt,
czyn.SZC_Ilosc as Ilosc,
czyn.SZC_TwrNumer as TwrNumer,
czyn.SZC_SZUId,
convert(decimal(15,2),czyn.SZC_CzasWykonania)/3600 as CzasWykonania,
convert(decimal(15,2),czyn.SZC_CzasRealizacji)/3600 as CzasRealizacji,
czyn.SZC_TwrNumer as CzynnoscNumer,
czyn.SZC_Id,
nag.SZN_Id,
czyn.SZC_Ilosc as IloscCzynnosci
		
from 
cdn.SrwZlcNag nag  ----  opisy zlecen serwisowych i cechy transakcji
join cdn.SrwZlcCzynnosci czyn on czyn.SZC_SZNId = nag.SZN_Id and czyn.SZC_SprzedazKoszt = 0  --- 1. czynno�ci na zleceniu
left join cdn.twrkarty with (nolock) on twr_gidnumer=czyn.SZC_TwrNumer  --- karty towarowe
-- where  	 CONCAT('ZSR-', nag.SZN_Numer, '/', RIGHT(nag.SZN_Rok, 2), '/', '0', nag.SZN_Miesiac, '/', nag.SZN_Seria) ='ZSR-143/24/01/S'
where nag.SZN_Rok=2024 
--and czyn.SZC_TwrNumer=2045

union all
--czynnosc koszt
	select 
case
when nag.SZN_Miesiac<9 then CONCAT('ZSR-', nag.SZN_Numer, '/', RIGHT(nag.SZN_Rok, 2), '/', '0', nag.SZN_Miesiac, '/', nag.SZN_Seria)
else CONCAT('ZSR-', nag.SZN_Numer, '/', RIGHT(nag.SZN_Rok, 2), '/', nag.SZN_Miesiac, '/', nag.SZN_Seria) end AS NrZlec,
nag.SZN_Rok, 
nag.SZN_Miesiac,
'Koszt' AS Rodzaj,
'C' as Typ,
czyn.SZC_TwrNazwa as Czynnosc,
czyn.SZC_TwrNazwa as Skladnik,
twr_kod as skladnikkod,
0  as Przychod,
czyn.SZC_CenaZakupu as Koszt,
czyn.SZC_Ilosc as Ilosc,
czyn.SZC_TwrNumer as TwrNumer,
czyn.SZC_SZUId,
convert(decimal(15,2),czyn.SZC_CzasWykonania)/3600 as CzasWykonania,
convert(decimal(15,2),czyn.SZC_CzasRealizacji)/3600 as CzasRealizacji,
czyn.SZC_TwrNumer as CzynnoscNumer,
czyn.SZC_Id,
nag.SZN_Id,
czyn.SZC_Ilosc as IloscCzynnosci

from 
cdn.SrwZlcNag nag
join cdn.SrwZlcCzynnosci czyn on czyn.SZC_SZNId = nag.SZN_Id and czyn.SZC_SprzedazKoszt = 1
left join cdn.twrkarty with (nolock) on twr_gidnumer=czyn.SZC_TwrNumer
where nag.SZN_Rok=2024 

		
union all 
--koszty z kalkulacji
select 
case
when nag.SZN_Miesiac<9 then CONCAT('ZSR-', nag.SZN_Numer, '/', RIGHT(nag.SZN_Rok, 2), '/', '0', nag.SZN_Miesiac, '/', nag.SZN_Seria)
else CONCAT('ZSR-', nag.SZN_Numer, '/', RIGHT(nag.SZN_Rok, 2), '/', nag.SZN_Miesiac, '/', nag.SZN_Seria) end AS NrZlec,
nag.SZN_Rok, 
nag.SZN_Miesiac,
'Koszt' AS Rodzaj,
'K' as Typ,
koszt.SZK_Kod as Nazwa,
koszt.SZK_Kod as Skl,
koszt.SZK_Kod as skladnikkod,
0  as Przychod,
koszt.SZK_Wartosc as Koszt,
1 as Ilosc,
null as TwrNumer,
null,
null as CzasWykonania,
null as CzasRealizacji,
null as CzynnoscNumer,
null,
nag.SZN_Id,
0 as IloscCzynnosci

from 
cdn.SrwZlcNag nag
join cdn.SrwZlcKoszty koszt on koszt.SZK_SZNId = nag.SZN_Id
where nag.SZN_Rok=2024 

--SKLADNIKI-------

	union all
--skladnik sprzedaz
select 
case
when nag.SZN_Miesiac<9 then CONCAT('ZSR-', nag.SZN_Numer, '/', RIGHT(nag.SZN_Rok, 2), '/', '0', nag.SZN_Miesiac, '/', nag.SZN_Seria)
else CONCAT('ZSR-', nag.SZN_Numer, '/', RIGHT(nag.SZN_Rok, 2), '/', nag.SZN_Miesiac, '/', nag.SZN_Seria) end AS NrZlec,
nag.SZN_Rok, 
nag.SZN_Miesiac,
'Sprzedaz' AS Rodzaj,
'S' as Typ,
czyn.SZC_TwrNazwa as Czynnosc,
sklad.SZS_TwrNazwa as Skladnik,
 twr_kod as skladnikkod,
sklad.SZS_WartoscPoRabacie as Przychod,
Convert(Decimal(15,2),TrE_KosztKsiegowy*Tre_KursM/Tre_KursL) as Koszt, --dodane - by?�o NULL
sklad.SZS_Ilosc as Ilosc,
sklad.SZS_TwrNumer,
czyn.SZC_SZUId,
null as CzasWykonania,
null as CzasRealizacji,
null as CzynnoscNumer,
czyn.SZC_Id,
nag.SZN_Id,
0 as IloscCzynnosci

from 
cdn.SrwZlcNag nag
join cdn.SrwZlcSkladniki sklad on sklad.SZS_SZNId = nag.SZN_Id and sklad.SZS_SprzedazKoszt = 0
left outer join cdn.SrwZlcCzynnosci czyn on sklad.SZS_SZCId = SZC_Id 
		---Dodane 
LEFT JOIN CDN.TraElem on TrE_ZlcTyp=4703 and TrE_ZlcNumer=SZS_Id and SZS_Ilosc=Tre_Ilosc
left join cdn.twrkarty with (nolock) on sklad.SZS_TwrNumer=twr_gidnumer
 where nag.SZN_Rok=2024 
-- and 	CONCAT('ZSR-', nag.SZN_Numer, '/', RIGHT(nag.SZN_Rok, 2), '/', '0', nag.SZN_Miesiac, '/', nag.SZN_Seria)='ZSR-143/24/01/S'

 union all
--skladnik koszt
select 
case
when nag.SZN_Miesiac<9 then CONCAT('ZSR-', nag.SZN_Numer, '/', RIGHT(nag.SZN_Rok, 2), '/', '0', nag.SZN_Miesiac, '/', nag.SZN_Seria)
else CONCAT('ZSR-', nag.SZN_Numer, '/', RIGHT(nag.SZN_Rok, 2), '/', nag.SZN_Miesiac, '/', nag.SZN_Seria) end AS NrZlec,
nag.SZN_Rok, 
nag.SZN_Miesiac,
'Koszt' AS Rodzaj,
'S' as Typ,
czyn.SZC_TwrNazwa as Czynnosc,
sklad.SZS_TwrNazwa as Skladnik,
twr_kod as skladnikkod,
0 as Przychod,
Convert(Decimal(15,2),TrE_KosztKsiegowy*Tre_KursM/Tre_KursL) as Koszt, --dodane - by?�o NULL
sklad.SZS_Ilosc as Ilosc,
sklad.SZS_TwrNumer,
czyn.SZC_SZUId,
null as CzasWykonania,
null as CzasRealizacji,
null as CzynnoscNumer,
czyn.SZC_Id,
nag.SZN_Id,
0 as IloscCzynnosci

from 
cdn.SrwZlcNag nag
join cdn.SrwZlcSkladniki sklad on sklad.SZS_SZNId = nag.SZN_Id and sklad.SZS_SprzedazKoszt = 1
left outer join cdn.SrwZlcCzynnosci czyn on sklad.SZS_SZCId = SZC_Id
	--Dodane
LEFT JOIN CDN.TraElem on TrE_ZlcTyp=4703 and TrE_ZlcNumer=SZS_Id and SZS_Ilosc=Tre_Ilosc
left join cdn.twrkarty with (nolock) on sklad.SZS_TwrNumer=twr_gidnumer
		) tog
		LEFT OUTER JOIN cdn.SrwZlcCzynnosci cz on cz.SZC_ID = tog.SZC_ID
		LEFT OUTER JOIN cdn.slowniki sl on sl.SLW_ID = cz.SZC_SlwStatus
		left outer join cdn.SrwZlcUrz urz on tog.SZC_SZUId=urz.SZU_Id
		left outer join cdn.SrwUrzadzenia urz2 on urz.SZU_SrUId=urz2.SrU_Id 
		--left outer join cdn.SrwUrzWlasc wlasc on wlasc.SUW_SrUId = urz2.SrU_Id and 
		left outer join ( select 
		TwC_TwrNumer,
		CASE WHEN TwC_Waluta<>'PLN' then  
			CASE TwC_Zaok
				WHEN 0.1000 THEN 
				convert(decimal(15,1),TwC_Wartosc) 
				WHEN 0.0100 THEN 
				convert(decimal(15,2),TwC_Wartosc) 
				WHEN 0.0010 THEN 
				convert(decimal(15,3),TwC_Wartosc) 
				WHEN 0.0001 THEN 
				convert(decimal(15,4),TwC_Wartosc) 
				ELSE 
				convert(decimal(15,2),TwC_Wartosc) END
				* (WaE_KursL/WaE_KursM) else TwC_Wartosc end as wartosc from cdn.TwrKarty 
	 join cdn.TwrCeny twc on Twr_GIDNumer=TwC_TwrNumer
	 left outer join cdn.WalElem wal on WaE_Lp = twc.TwC_NrKursu and WaE_Symbol = TwC_Waluta
	 and wal.wae_kursts = (
							select max(wal2.wae_kursts) 
							from cdn.walelem wal2 
							where wal2.wae_symbol = wal.wae_symbol and wal2.WaE_Lp = twc.TwC_NrKursu 
							and wae_kursts< TwC_CzasModyfikacji )
	where TwC_TwrLp = 0 
		) ceny on ceny.TwC_TwrNumer = tog.TwrNumer
		
		UNION ALL 
	select 			
case
when nag.SZN_Miesiac<9 then CONCAT('ZSR-', nag.SZN_Numer, '/', RIGHT(nag.SZN_Rok, 2), '/', '0', nag.SZN_Miesiac, '/', nag.SZN_Seria)
else CONCAT('ZSR-', nag.SZN_Numer, '/', RIGHT(nag.SZN_Rok, 2), '/', nag.SZN_Miesiac, '/', nag.SZN_Seria) end AS NrZlec,
nag.SZN_Rok, 
nag.SZN_Miesiac,
	'<nieznany>' as Rodzaj,
	
	null as Typ,
	null as Czynnosc,
	null as Skladnik,
	null as skladnikkod,
	urz2.SrU_Nazwa as urzadzenie,
	0 as Przychod,
	0 as Koszt,
	nag.SZN_Id,
	null as czaswykonania,
	null as CzasRealizacji,
	null as CzynnoscNumer,
	null as StatusCzynnosc,
	null as Ilosc
	FROM 
	cdn.SrwZlcNag nag
	join cdn.SrwZlcUrz urz on nag.SZN_Id = urz.SZU_SZNId
	join cdn.SrwUrzadzenia urz2 on urz.SZU_SrUId=urz2.SrU_Id 
	where SZU_Id not in(select szc_szuid from cdn.SrwZlcCzynnosci where SZC_SZUId<>0) 
	
	)c
	join cdn.SrwZlcNag nagl on c.SZN_Id  = nagl.SZN_Id	
	left join CDN.Atrybuty ON CDN.Atrybuty.Atr_ObiNumer = nagl.SZN_Id and   CDN.Atrybuty.Atr_AtkId = 224
	left join cdn.Atrybuty A1 on A1.Atr_ObiTyp = 4700 and A1.Atr_ObiNumer = nagl.SZN_Id and A1.Atr_AtkId = 251
	left join cdn.Atrybuty A2 on A2.Atr_ObiTyp = 4700 and A2.Atr_ObiNumer = nagl.SZN_Id and A2.Atr_AtkId = 252
	left outer join cdn.KntKarty knt on knt.Knt_GIDTyp=nagl.SZN_KntTyp AND knt.Knt_GIDNumer=nagl.SZN_KntNumer
	left outer join cdn.tranag trn on trn.trn_Zannumer = nagl.SZN_ID and trn.trn_ZanTyp = 4700  and trn.trn_gidtyp in(2001,2033,1616)
	LEFT OUTER JOIN cdn.OpeKarty op on Ope_Gidnumer = nagl.SZN_OpeNumerO
	LEFT OUTER JOIN cdn.Slowniki sl on nagl.SZN_SlwStatus = sl.SLW_ID
	LEFT JOIN (SELECT MAX(SUR_Kod)SUR_Kod,MAX(SrU_Nazwa)SrU_Nazwa,MAX(SUP_ParWartoscS)SUP_ParWartoscS,SZU_SZNId
					 FROM cdn.SrwZlcUrz   
					 join cdn.SrwUrzadzenia on SrU_Id=SZU_SrUId
					 join cdn.SrwUrzRodzaje on SUR_Id=SrU_SURId
					 join cdn.SrwUrzParam on SrU_Id=SUP_ObiNumer 
					 where SUP_SUDId = 5
					 GROUP BY SZU_SZNId) urz ON nagl.SZN_Id=urz.SZU_SZNId
 where --NrZlec='ZSR-119/24/02/S' and 
	  c.SZN_Rok=2024
	  and c.Rodzaj <> '<nieznany>'
		group by c.Typ, c.SZN_Id, 

		c.NrZlec, 	c.SZN_Rok, 
c.SZN_Miesiac,c.Rodzaj, c.Czynnosc,
		c.Skladnik,c.skladnikkod,c.Urzadzenie,nagl.SZN_DataRozpoczecia,trn.trn_Zannumer--trn.trn_Gidnumer
		,nagl.SZN_DataWystawienia,nagl.SZN_Stan,knt.Knt_Akronim,knt.Knt_Nazwa1,c.CzasWykonania,c.CzasRealizacji,KNT.Knt_Wojewodztwo,op.Ope_Ident,c.StatusCzynnosc,
		KNT.Knt_Powiat,KNT.Knt_Gmina,KNT.Knt_Miasto,Trn_GidTyp, Trn_SpiTyp, Trn_TrnTyp, Trn_TrnNumer, Trn_TrnRok, Trn_TrnSeria, Trn_TrnMiesiac, Trn_TrnLp, nagl.szn_id,sl.SLW_WartoscS,
		--Nagl.SZN_Numer,Nagl.SZN_Rok,Nagl.SZN_Seria,Nagl.SZN_Miesiac,nagl.SZN_CechaOpis,nagl.SZN_Opis,
	--	isnull(substring( CDN.NumerDokumentu(4700,0,0,nagl.SZN_Numer,nagl.SZN_Rok,nagl.SZN_Seria,nagl.SZN_Miesiac),1,115),'<nieznany>'),
		isnull(nagl.SZN_Opis,'<nieznany>'),
		isnull(nagl.SZN_CechaOpis,'<nieznany>'),
		isnull(urz.SUR_Kod,'<nieznany>') ,
		isnull(urz.SrU_Nazwa,'<nieznany>'),
		isnull(urz.SUP_ParWartoscS,'<nieznany>'),
A1.Atr_Wartosc,
A2.Atr_Wartosc,
c.CzynnoscNumer,
trn.TrN_DokumentObcy,
CDN.Atrybuty.Atr_Wartosc,
knt.knt_Akronim,
knt.Knt_Nazwa1
)

SELECT sum(IloscCzynnosci) AS Roboczogodziny, Operator, Skladnik, NrZlec,
	SZN_Rok, 
SZN_Miesiac
FROM qwerty
WHERE Skladnik = 'roboczogodzina;'
GROUP BY Operator, Skladnik, NrZlec, SZN_Rok, 
SZN_Miesiac

	

		
