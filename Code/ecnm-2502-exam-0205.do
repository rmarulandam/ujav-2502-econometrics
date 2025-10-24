/*==============================================================================
   ANÁLISIS DE ELASTICIDAD PRECIO CRUZADA
   Proyecto: Estimación de elasticidades cruzadas entre bienes y servicios
   Autor: Econometrista
   Fecha: Octubre 2025
==============================================================================*/

* --- 1. SETUP ---
clear all

* Defining directory structure using local macros
global project_root "C:\repos\ujav-2502-econometrics"
global code_dir "$project_root\Code"
global figures_dir "$project_root\Figures"
global tables_dir "$project_root\Tables"
global data_dir "$project_root\Data"

cd "$project_root"

* --- 2. LOAD AND PREPARE DATA ---

* Import data from Excel
import excel "$data_dir/ecnm-2502-exam-0205.xlsx", sheet("Inflacion") firstrow clear

* Convertir la fecha a formato de Stata (si es necesario)
*gen fecha_stata = date(Date, "YMD")
*format fecha_stata %td
*order fecha_stata Date
*drop Date
*rename fecha_stata Date

* Mostrar información básica de los datos
describe
summarize

* Contar el número de bienes/servicios (columnas menos la fecha)
quietly ds Date, not
local num_bienes = r(varcount)
display "Número total de bienes y servicios: `num_bienes'"

* Crear matriz para almacenar estadísticas descriptivas
quietly ds Date, not
local varlist `r(varlist)'

* Tabla de estadísticas descriptivas completa
summarize `varlist', separator(10)

* Exportar estadísticas descriptivas a una tabla más detallada
preserve
    * Crear dataset temporal con estadísticas
    clear
    set obs `num_bienes'
    
    * Generar variables para almacenar estadísticas
    gen str100 variable = ""
    gen obs = .
    gen media = .
    gen desv_est = .
    gen minimo = .
    gen maximo = .
    gen p25 = .
    gen p50 = .
    gen p75 = .
restore

* Calcular estadísticas detalladas para cada bien

local contador = 1
foreach var of varlist `varlist' {
    quietly summarize `var', detail
    
    * Mostrar solo los primeros 20 para no saturar la pantalla
    if `contador' <= 20 {
        display %20s "`var'" _col(25) %7.0f r(N) _col(35) %9.4f r(mean) ///
                _col(47) %9.4f r(sd) _col(58) %9.4f r(min) _col(69) %9.4f r(p25) ///
                _col(80) %9.4f r(p50) _col(91) %9.4f r(p75) _col(102) %9.4f r(max)
    }
    local contador = `contador' + 1
}

/*------------------------------------------------------------------------------
   PARTE B: ESTIMACIÓN DE ELASTICIDADES PRECIO CRUZADAS
------------------------------------------------------------------------------*/

* Obtener lista de variables (excluyendo Date)
quietly ds Date, not
local varlist `r(varlist)'
local num_vars : word count `varlist'

* Crear matriz para almacenar coeficientes de elasticidad
matrix Elasticidades = J(`num_vars', `num_vars', .)

* Crear lista de nombres para las filas y columnas de la matriz
local nombres ""
foreach var of varlist `varlist' {
    local nombres "`nombres' `var'"
}

* Estimar elasticidades usando loops anidados
display "Iniciando estimaciones..."
local tiempo_inicio = "$S_TIME"

* Contador para mostrar progreso
local total_reg = `num_vars' * `num_vars'
local contador_reg = 0

* Loop externo: para cada bien X (variable dependiente)
local i = 1
foreach var_x of varlist `varlist' {
    
    * Mostrar progreso cada 10 bienes
    if mod(`i', 10) == 0 {
        display "Procesando bien `i' de `num_vars'... (Fila `i' de la matriz)"
    }
    
    * Loop interno: para cada bien Y (variable independiente - precio del bien relacionado)
    local j = 1
    foreach var_y of varlist `varlist' {
        
        * Estimación de la regresión: inflación_X = beta * inflación_Y + error
        * Beta representa la elasticidad precio cruzada
        quietly {
            capture regress `var_x' `var_y'
            
            * Verificar si la regresión fue exitosa
            if _rc == 0 {
                * Almacenar el coeficiente estimado (beta)
                matrix Elasticidades[`i', `j'] = _b[`var_y']
            }
            else {
                * Si hay error, almacenar missing value
                matrix Elasticidades[`i', `j'] = .
            }
        }
        
        local j = `j' + 1
        local contador_reg = `contador_reg' + 1
    }
    
    local i = `i' + 1
}

* Asignar nombres a filas y columnas de la matriz
matrix rownames Elasticidades = `nombres'
matrix colnames Elasticidades = `nombres'

/*------------------------------------------------------------------------------
   PRESENTACIÓN DE RESULTADOS
------------------------------------------------------------------------------*/

matrix list Elasticidades[1..8, 1..8], format(%8.4f)

* Exportar matriz completa a archivo
preserve
    clear
    svmat Elasticidades, names(col)
    export excel using "matriz_elasticidades_completa.xlsx", firstrow(variables) replace
restore

/*------------------------------------------------------------------------------
   ANÁLISIS E INTERPRETACIÓN
------------------------------------------------------------------------------*/

display _newline(2)
display "{hline 80}"
display "INTERPRETACIÓN DE RESULTADOS"
display "{hline 80}"
display _newline(1)

display "1. INTERPRETACIÓN GENÉRICA DE LOS COEFICIENTES:"
display "   =============================================="
display "   "
display "   - Elasticidad > 0: Los bienes son SUSTITUTOS"
display "     Cuando el precio del bien Y aumenta en 1%, la inflación (cambio en precio)"
display "     del bien X aumenta en β%, indicando que son sustitutos."
display "     "
display "   - Elasticidad < 0: Los bienes son COMPLEMENTARIOS"
display "     Cuando el precio del bien Y aumenta en 1%, la inflación del bien X"
display "     disminuye en |β|%, indicando que son complementarios."
display "     "
display "   - Elasticidad ≈ 0: Los bienes son INDEPENDIENTES"
display "     Los cambios en el precio de Y no afectan significativamente al bien X."
display "     "
display "   - Diagonal (i=j): Representa la relación de cada bien consigo mismo"
display "     Estos valores deben interpretarse con cautela."

display _newline(1)
display "2. ANÁLISIS ESTADÍSTICO DE LA MATRIZ:"
display "   ===================================="

* Calcular estadísticas sobre las elasticidades estimadas
preserve
    clear
    svmat Elasticidades
    
    * Eliminar elementos de la diagonal para el análisis
    local k = 1
    foreach var of varlist Elasticidades* {
        quietly replace `var' = . in `k'
        local k = `k' + 1
    }
    
    * Calcular estadísticas
    egen todas_elasticidades = rowfirst(Elasticidades*)
    
    quietly summarize todas_elasticidades, detail
    
    display "   Media de elasticidades (sin diagonal):     " %8.4f r(mean)
    display "   Mediana de elasticidades:                  " %8.4f r(p50)
    display "   Desviación estándar:                       " %8.4f r(sd)
    display "   Elasticidad mínima:                        " %8.4f r(min)
    display "   Elasticidad máxima:                        " %8.4f r(max)
    display "   "
    
    * Contar proporciones
    quietly count if todas_elasticidades > 0 & todas_elasticidades != .
    local positivos = r(N)
    quietly count if todas_elasticidades < 0 & todas_elasticidades != .
    local negativos = r(N)
    quietly count if todas_elasticidades != .
    local total_validos = r(N)
    
    local prop_sustitutos = 100 * `positivos' / `total_validos'
    local prop_complementarios = 100 * `negativos' / `total_validos'
    
    display "   Proporción de pares SUSTITUTOS:            " %5.2f `prop_sustitutos' "%"
    display "   Proporción de pares COMPLEMENTARIOS:       " %5.2f `prop_complementarios' "%"
    
restore

display _newline(1)
display "3. EJEMPLOS DE INTERPRETACIÓN:"
display "   ============================="
display "   "
display "   Ejemplo 1: Si Elasticidad[Arroz, Pasta] = 0.25"
display "   → Un aumento de 1% en la inflación de Pasta se asocia con un aumento"
display "     de 0.25% en la inflación de Arroz, sugiriendo que son sustitutos."
display "   "
display "   Ejemplo 2: Si Elasticidad[Gasolina, Bus] = -0.15"
display "   → Un aumento de 1% en la inflación del transporte en Bus se asocia"
display "     con una disminución de 0.15% en la inflación de Gasolina,"
display "     sugiriendo que son complementarios."

display _newline(2)
display "4. CONSIDERACIONES METODOLÓGICAS:"
display "   ================================"
display "   "
display "   - Estas elasticidades son estimadas mediante regresiones simples"
display "   - No controlan por otros factores que podrían afectar los precios"
display "   - Son medidas de asociación, no necesariamente causalidad"
display "   - La significancia estadística individual debe verificarse para"
display "     interpretaciones más robustas"
display "   - Considerar análisis de significancia estadística para identificar"
display "     relaciones verdaderamente significativas"

/*------------------------------------------------------------------------------
   ANÁLISIS ADICIONAL: IDENTIFICAR PARES MÁS IMPORTANTES
------------------------------------------------------------------------------*/

display _newline(2)
display "{hline 80}"
display "ANÁLISIS ADICIONAL: PARES CON MAYORES ELASTICIDADES"
display "{hline 80}"
display _newline(1)

* Crear dataset con todos los pares y sus elasticidades
preserve
    clear
    set obs `=`num_vars'*`num_vars''
    gen str100 bien_x = ""
    gen str100 bien_y = ""
    gen elasticidad = .
    
    local obs = 1
    local i = 1
    foreach var_x of varlist `varlist' {
        local j = 1
        foreach var_y of varlist `varlist' {
            * Excluir la diagonal
            if `i' != `j' {
                quietly {
                    replace bien_x = "`var_x'" in `obs'
                    replace bien_y = "`var_y'" in `obs'
                    replace elasticidad = Elasticidades[`i', `j'] in `obs'
                }
                local obs = `obs' + 1
            }
            local j = `j' + 1
        }
        local i = `i' + 1
    }
    
    * Eliminar observaciones vacías
    drop if elasticidad == .
    
    * Top 10 sustitutos más fuertes (elasticidades positivas más altas)
    display "TOP 10 PARES DE BIENES SUSTITUTOS (Elasticidades positivas más altas):"
    display "{hline 100}"
    gsort -elasticidad
    list bien_x bien_y elasticidad in 1/10, noobs separator(0) abbreviate(30)
    
    display _newline(1)
    
    * Top 10 complementarios más fuertes (elasticidades negativas más bajas)
    display "TOP 10 PARES DE BIENES COMPLEMENTARIOS (Elasticidades negativas más bajas):"
    display "{hline 100}"
    gsort elasticidad
    list bien_x bien_y elasticidad in 1/10, noobs separator(0) abbreviate(30)
    
    * Exportar tabla completa de elasticidades en formato largo
    export excel using "elasticidades_formato_largo.xlsx", firstrow(variables) replace
    
restore

display _newline(2)
display "Archivos generados:"
display "  1. matriz_elasticidades_completa.xlsx - Matriz completa 181x181"
display "  2. elasticidades_formato_largo.xlsx - Formato largo para análisis adicional"
display "  3. analisis_elasticidad.log - Log completo del análisis"

* Cerrar log
log close

display _newline(1)
display "{hline 80}"
display "ANÁLISIS COMPLETADO EXITOSAMENTE"
display "{hline 80}"

/*==============================================================================
   FIN DEL PROGRAMA
==============================================================================*/
