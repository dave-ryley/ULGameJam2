"""
    Usage: Run this (quick and dirty) file with python3 to compile the src carts to the build cart.
    Project: UL Gamejam 2 - Simplicity - Game
    Description: Pico-8 file merger for our gamejam team.
    Author: Darren Kearney
    Author URI: https://darrenk.net
"""

def pico8_get_chunk_from_file( label, filepath ):
    
    # Vars
    chunk = ""
    is_in_chunk = False

    # Open target file for reading
    with open( filepath, 'r' ) as h:
        haystack = h.readlines()

    # Detect chunk by label and append lines to output variable
    for line in haystack:
        if line == label or line[:-1:] == label:
            is_in_chunk = True
            print("    + Found chunk '{}'".format(label))
            continue

        if is_in_chunk:
            
            # Detect out of chunk
            if line[0:2] == "__" and line[-3:-1] == "__":
                is_in_chunk = False
                print("      Detected chunk '{}', Leaving '{}'".format(line[:-1],label))
                break

            chunk += "{}".format(line)

    if chunk == "":
        print("    - No chunk found for '{}' in '{}'".format(label, filepath))

    return chunk

print("Reading includes file")
with open('includes', 'r') as f:
    read_data = f.read()

includes = {}

for i in read_data.split():
    k=i.split('=')[0]
    v=i.split('=')[1]
    includes[k] = v

chunks = {
    '__pre__': '',
    '__gfx__': '',
    '__gff__': '',
    '__lua__': '',
    '__map__': '',
    '__sfx__': '',
    '__music__': ''
}


# Go into each include file
for filepath in includes.values():
    print(" + {}".format( filepath ))

    if filepath == includes['__pre__']: 
        # Read peamble
        with open(filepath, 'r') as p:
            preamble_data = p.read()
        chunks['__pre__'] = "{}".format(preamble_data)

    if filepath == "src/lua/lua.p8":
        chunks['__lua__'] = pico8_get_chunk_from_file( "__lua__", filepath ) 


    if filepath == "src/assets/gfx.p8":
        chunks['__gfx__'] = pico8_get_chunk_from_file( "__gfx__", filepath )
        chunks['__gff__'] = pico8_get_chunk_from_file( "__gff__", filepath )
        chunks['__map__'] = pico8_get_chunk_from_file( "__map__", filepath )
 
    if filepath == "src/assets/sfx.p8":
        chunks['__sfx__'] = pico8_get_chunk_from_file( "__sfx__", filepath )
        chunks['__music__'] = pico8_get_chunk_from_file( "__music__", filepath )

# print(chunks)

# Stitch the output strings together

output = ""

def stitch_chunks(output, label):
    output += "{}\n{}".format(label, chunks[label])

# print(output)

## Preamble
output += chunks['__pre__']
# Lua code
output += "\n__lua__\n{}".format(chunks['__lua__'])
# Art assets
output += "\n__gfx__\n{}".format(chunks['__gfx__'])
output += "\n__gff__\n{}".format(chunks['__gff__'])
output += "\n__map__\n{}".format(chunks['__map__'])
# Audio assets
output += "\n__sfx__\n{}".format(chunks['__sfx__'])
output += "\n__music__\n{}".format(chunks['__music__'])

# Append all strings together for build
with open('bin/jamthegame.p8', 'w') as build:
    build.write(output)

print("Done.")
