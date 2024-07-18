WITH iap AS (

	SELECT
    
        (
    
        SELECT COUNT(*)
        
        FROM (
        
            SELECT DISTINCT
            
                  cab.TIPMOV AS TIPO
                , cab.NUNOTA AS NU
                , cab.NUMNOTA AS NOTA
                , ped.NUMNOTA AS OC
                , cab.CODPARC AS COD_PARC
                , par.NOMEPARC AS PARCEIRO
                , ite.SEQUENCIA AS ITEM
                , ite.CODPROD AS COD_PROD
                , pro.DESCRPROD AS PRODUTO
                , (CASE WHEN ite.DTINICIO IS NULL THEN ped.DTFATUR ELSE ite.DTINICIO END) AS PREVISAO
                , cab.DTNEG AS ENTREGA
                , (CASE WHEN ite.DTINICIO IS NULL THEN cab.DTNEG - ped.DTFATUR ELSE cab.DTNEG - ite.DTINICIO END) AS ATRASO
                
            FROM TGFCAB cab
            
                INNER JOIN TGFITE ite ON cab.NUNOTA = ite.NUNOTA
                INNER JOIN TGFVAR var ON cab.NUNOTA = var.NUNOTA
                INNER JOIN TGFCAB ped ON var.NUNOTAORIG = ped.NUNOTA
                INNER JOIN TGFPAR par ON cab.CODPARC = par.CODPARC
                INNER JOIN TGFPRO pro ON ite.CODPROD = pro.CODPROD
                
            WHERE cab.CODEMP = 1
            
            AND cab.CODPARC = :CODPARC
            AND cab.TIPMOV IN ('O', 'C')
            AND (cab.DTNEG BETWEEN :DTNEG.ini AND :DTNEG.fin)
            AND par.AD_FORNPARTAVAL = 'S'
                        
            ORDER BY ATRASO DESC
            
            )
    
        ) AS ENTREGAS,
    

        (
        
        SELECT COUNT(CASE WHEN ATRASO <= 0 THEN ATRASO END) 
    
        FROM (
        
            SELECT DISTINCT
            
                  cab.TIPMOV AS TIPO
                , cab.NUNOTA AS NU
                , cab.NUMNOTA AS NOTA
                , ped.NUMNOTA AS OC
                , cab.CODPARC AS COD_PARC
                , par.NOMEPARC AS PARCEIRO
                , ite.SEQUENCIA AS ITEM
                , ite.CODPROD AS COD_PROD
                , pro.DESCRPROD AS PRODUTO
                , (CASE WHEN ite.DTINICIO IS NULL THEN ped.DTFATUR ELSE ite.DTINICIO END) AS PREVISAO
                , cab.DTNEG AS ENTREGA
                , (CASE WHEN ite.DTINICIO IS NULL THEN cab.DTNEG - ped.DTFATUR ELSE cab.DTNEG - ite.DTINICIO END) AS ATRASO        
            FROM TGFCAB cab
            
                INNER JOIN TGFITE ite ON cab.NUNOTA = ite.NUNOTA
                INNER JOIN TGFVAR var ON cab.NUNOTA = var.NUNOTA
                INNER JOIN TGFCAB ped ON var.NUNOTAORIG = ped.NUNOTA
                INNER JOIN TGFPAR par ON cab.CODPARC = par.CODPARC
                INNER JOIN TGFPRO pro ON ite.CODPROD = pro.CODPROD
                
            WHERE cab.CODEMP = 1
            
            AND cab.CODPARC = :CODPARC
            AND cab.TIPMOV IN ('O', 'C')
            AND (cab.DTNEG BETWEEN :DTNEG.ini AND :DTNEG.fin)
            AND par.AD_FORNPARTAVAL = 'S'
            
            ORDER BY ATRASO DESC
            
            )
        
        WHERE ATRASO <= 0
        
        ) AS NO_PRAZO
    
    FROM DUAL

)

SELECT (NO_PRAZO / ENTREGAS) AS IAP
FROM iap
