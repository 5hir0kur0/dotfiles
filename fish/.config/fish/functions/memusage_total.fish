function memusage_total -d 'sum the memory usage output line of memusage into a single number'
    memusage $argv | paste -sd+ | bc
end
