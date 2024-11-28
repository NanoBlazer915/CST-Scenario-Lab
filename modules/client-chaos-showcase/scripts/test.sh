# Create a list of CPUs on NUMA node 1
numa1_cpus=$(lscpu | awk '/NUMA node1 CPU\(s\)/{print $NF}' | tr ',' '\n')

# Convert CPU ranges to a list of individual CPUs
cpus=""
for range in $numa1_cpus; do
  if [[ $range == *"-"* ]]; then
    start=${range%-*}
    end=${range#*-}
    cpus+=" $(seq $start $end)"
  else
    cpus+=" $range"
  fi
done

# Generate the CPU mask
mask=$(printf "%x\n" $(( $(echo $cpus | tr ' ' '\n' | awk '{sum += 2 ** $0} END {print sum}') )))

# Display the mask
echo "CPU mask for NUMA node 1: $mask"
export mask
echo "Mask is: $mask"
for irq in {37..44}; do
  echo "Setting affinity for IRQ $irq"
  sudo sh -c "echo $mask > /proc/irq/$irq/smp_affinity"
done
for irq in {37..44}; do
  echo "IRQ $irq smp_affinity_list:"
  cat /proc/irq/$irq/smp_affinity_list
done

