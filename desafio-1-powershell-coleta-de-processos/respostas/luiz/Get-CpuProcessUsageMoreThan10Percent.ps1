# Baseado no caso do Stackoverflow: https://stackoverflow.com/a/42088905

# Obtendo o número de processadores lógicos (para os calculos)
$CPUCores = (Get-WMIObject Win32_ComputerSystem).NumberOfLogicalProcessors

# Obtendo os contadores de tempo de processador de todos os processos do computador e ordenando do que mais esta usa CPU para o que menos usando
$ProcTimeList = (Get-Counter "\Process(*)\% Processor Time").CounterSamples | Sort-Object -Property CookedValue -Descending

# Cria um array de objetos PS
$ProcessList = @()

# Interação sobre todos os processos e seus tempos de uso de CPU
foreach ($ProcTime in $ProcTimeList) {
    # Exclui os processos "idle" (tempo ocioso de CPU) e "_total" (soma de todos os processos)
    if ($ProcTime.InstanceName -notcontains "idle" -and $ProcTime.InstanceName -notcontains "_total") {
        # Pega o valor do uso de CPU do processo e divide pelo número de cores
        $CPUUsage = [Math]::Round(($ProcTime.CookedValue / $CPUCores))

        # Se o uso de CPU for maior que 9%, cria um objeto e joga ele no array
        if ($CPUUsage -gt 9) {
            $ProcessCPUInfo = New-Object PSObject -Property  @{Name=$ProcTime.InstanceName;CPU=$CPUUsage}
            $ProcessList += $ProcessCPUInfo
        }
    }
}

# Exibe o array de objetos, ordenando por uso de CPU do que mais usa para o que menos usa.
$ProcessList | Sort-Object -Property CPU -Descending | Select-Object -Property Name,CPU
