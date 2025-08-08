import re
from typing import Dict, List, Set

def find_all_procedures(content: str) -> Dict[str, List[int]]:
    """Find all procedure definitions and their line numbers."""
    procedures = {}
    lines = content.split('\n')
    
    for i, line in enumerate(lines):
        # Match PROC followed by procedure name
        match = re.match(r'^\s*(\d+\s+)?PROC\s+([A-Z][A-Z0-9]*)\s*$', line.strip(), re.IGNORECASE)
        if match:
            proc_name = match.group(2).upper()
            if proc_name not in procedures:
                procedures[proc_name] = []
            procedures[proc_name].append(i)
    
    return procedures

def find_procedure_calls(content: str, proc_names: Set[str]) -> Dict[str, List[int]]:
    """Find all procedure calls and their line numbers."""
    calls = {}
    lines = content.split('\n')
    
    for proc_name in proc_names:
        calls[proc_name] = []
        
        for i, line in enumerate(lines):
            # Skip comment lines and empty lines
            stripped = line.strip()
            if not stripped or stripped.startswith('#'):
                continue
                
            # Look for procedure calls (proc name followed by optional colon or end of statement)
            # This regex looks for the procedure name as a whole word
            pattern = r'\b' + re.escape(proc_name) + r'\b(?=\s*[:$\s]|$)'
            if re.search(pattern, line, re.IGNORECASE):
                # Make sure it's not a PROC definition line
                if not re.match(r'^\s*(\d+\s+)?PROC\s+' + re.escape(proc_name) + r'\s*$', line.strip(), re.IGNORECASE):
                    calls[proc_name].append(i)
    
    return calls

def generate_short_names(proc_names: List[str]) -> Dict[str, str]:
    """Generate shortest possible unique names for procedures."""
    short_names = {}
    used_names = set()
    
    # Sort by length first, then alphabetically for consistent results
    sorted_procs = sorted(proc_names, key=lambda x: (len(x), x))
    
    for proc_name in sorted_procs:
        # Try progressively longer prefixes
        for length in range(1, len(proc_name) + 1):
            candidate = proc_name[:length]
            if candidate not in used_names:
                short_names[proc_name] = candidate
                used_names.add(candidate)
                break
        else:
            # If we somehow can't find a unique name, use the full name
            short_names[proc_name] = proc_name
            used_names.add(proc_name)
    
    return short_names

def replace_procedures_and_calls(content: str, name_mapping: Dict[str, str]) -> str:
    """Replace procedure definitions and calls with shortened names."""
    lines = content.split('\n')
    
    for i, line in enumerate(lines):
        # Replace procedure definitions
        for old_name, new_name in name_mapping.items():
            # Replace PROC definitions
            proc_pattern = r'^(\s*\d*\s*PROC\s+)' + re.escape(old_name) + r'(\s*)$'
            match = re.match(proc_pattern, line, re.IGNORECASE)
            if match:
                lines[i] = match.group(1) + new_name + match.group(2)
                continue
            
            # Replace procedure calls (but not in comments)
            if not line.strip().startswith('#') and line.strip():
                # Look for the procedure name as a whole word
                call_pattern = r'\b' + re.escape(old_name) + r'\b'
                lines[i] = re.sub(call_pattern, new_name, lines[i], flags=re.IGNORECASE)
    
    return '\n'.join(lines)

def analyze_and_shorten_procedures(input_file: str, output_file: str):
    """Main function to analyze and shorten procedure names."""
    
    # Read the input file
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find all procedures
    procedures = find_all_procedures(content)
    proc_names = set(procedures.keys())
    
    print(f"Found {len(proc_names)} unique procedures:")
    for name in sorted(proc_names):
        print(f"  {name} (defined {len(procedures[name])} times)")
    
    # Find all procedure calls
    calls = find_procedure_calls(content, proc_names)
    
    print(f"\nProcedure call statistics:")
    for name in sorted(proc_names):
        call_count = len(calls[name])
        def_count = len(procedures[name])
        print(f"  {name}: {def_count} definitions, {call_count} calls")
    
    # Generate shortened names
    name_mapping = generate_short_names(list(proc_names))
    
    print(f"\nName mapping:")
    for old_name in sorted(name_mapping.keys()):
        new_name = name_mapping[old_name]
        savings = len(old_name) - len(new_name)
        print(f"  {old_name} -> {new_name} (saves {savings} chars)")
    
    # Calculate total character savings
    total_savings = 0
    for old_name, new_name in name_mapping.items():
        char_diff = len(old_name) - len(new_name)
        # Count savings from definitions and calls
        total_occurrences = len(procedures[old_name]) + len(calls[old_name])
        total_savings += char_diff * total_occurrences
    
    print(f"\nTotal character savings: {total_savings}")
    
    # Replace procedures and calls
    modified_content = replace_procedures_and_calls(content, name_mapping)
    
    # Write the output file
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(modified_content)
    
    print(f"\nModified code written to: {output_file}")

if __name__ == "__main__":
    input_file = "tsbv2.bas"  # Input file name
    output_file = "tsbv2_shortened.bas"  # Output file name
    
    analyze_and_shorten_procedures(input_file, output_file)