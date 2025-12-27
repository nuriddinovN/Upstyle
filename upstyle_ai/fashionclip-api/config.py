# config.py
from collections import OrderedDict
import os

# --- Cloud Run Model Path ---
# Use a relative path, which works locally and in Docker.
ONNX_MODEL_PATH = os.getenv('ONNX_MODEL_PATH', 'models/fashionclip.simplified.onnx')
HF_MODEL_ID = "patrickjohncyh/fashion-clip"

# --- CLIP Constants ---
CLIP_MEAN = [0.48145466, 0.4578275, 0.40821073]
CLIP_STD  = [0.26862954, 0.26130258, 0.27577711]
INPUT_SIZE = 224
LOGIT_SCALE = 100.0 

# --- Attribute Dictionary ---
PROMPT_TEMPLATE = "a {}" 

ATTRIBUTE_CANDIDATES = OrderedDict([
    ("category", [
        "t-shirt","shirt","blouse","tank top","crop top","hoodie","sweatshirt",
        "cardigan","sweater","jacket","coat","trench coat","puffer jacket",
        "dress","mini dress","midi dress","maxi dress","evening gown",
        "jeans","cargo pants","trousers","leggings","shorts","skirt",
        "saree","kurta","abaya","kimono",
        "suit","blazer","vest","jumpsuit","romper","activewear","swimwear"
    ]),
    ("sub_category", [
        "graphic tee","polo","henley","button-down","oxford shirt",
        "tube top","halter top","off-shoulder","tank racerback",
        "pleated skirt","pencil skirt","wrap skirt","tennis skirt",
        "biker shorts","cargo shorts","baggy jeans","skinny jeans",
        "wide-leg trousers","bootcut jeans","mom jeans",
        "down jacket","parka","leather jacket","denim jacket"
    ]),
    ("gender", ["male fashion","female fashion","unisex fashion"]),
    ("primary_color", [
        "black","white","gray","blue","red","green","yellow","brown","pink","purple","orange"
    ]),
    ("secondary_color",
  [
    "Jet Black",
    "Optical White",
    "Charcoal Grey",
    "Heather Grey",
    "Navy Blue",
    "Midnight Blue",
    "Denim / Indigo",
    "Sky Blue",
    "Teal / Petrol",
    "Royal Blue",
    "Crimson Red",
    "Burgundy / Maroon",
    "Fuchsia / Magenta",
    "Blush / Dusty Pink",
    "Forest Green",
    "Olive / Khaki",
    "Sage / Mint",
    "Kelly / Emerald Green",
    "Mustard Yellow",
    "Butter / Pastel Yellow",
    "Chocolate Brown",
    "Camel / Tan",
    "Beige / Sand",
    "Taupe / Greige",
    "Cream / Ecru",
    "Terracotta / Rust",
    "Burnt Orange",
    "Plum / Eggplant",
    "Lavender / Lilac",
    "Metallic Gold",
    "Metallic Silver"
    ]),
    ("accent_color", ["gold","silver","metallic","neon","multicolor","holographic"]),
    ("pattern", [
        "solid color","striped","checked","plaid","gingham",
        "floral","botanical","paisley",
        "geometric","abstract print","animal print","leopard","snake",
        "tie-dye","camouflage","graphic print","logo print","embroidered"
    ]),
    ("material", [
        "cotton","organic cotton","denim","wool","merino wool","cashmere",
        "silk","linen","chiffon","satin","tulle","polyester","viscose",
        "nylon","acrylic","leather","faux leather","suede","knit","ribbed knit",
        "mesh","lace","corduroy","velvet"
    ]),
    ("fit", [
        "slim fit","regular fit","relaxed fit","oversized","tailored","boxy","bodycon"
    ]),
    ("silhouette", [
        "A-line","straight","fitted","flared","peplum","ball gown","empire waist",
        "asymmetric","wrap silhouette","shift","sheath"
    ]),
    ("neckline", [
        "crew neck","v-neck","scoop neck","square neck","sweetheart","halter",
        "boat neck","turtleneck","collared","off-shoulder"
    ]),
    ("sleeve", [
        "sleeveless","short sleeve","half sleeve","3/4 sleeve","long sleeve",
        "bell sleeve","balloon sleeve","raglan","cap sleeve","kimono sleeve"
    ]),
    ("length", [
        "crop length","waist length","hip length","knee length","midi length",
        "ankle length","floor length"
    ]),
    ("rise", ["high-rise","mid-rise","low-rise"]),
    ("closure_type", [
        "zipper","buttons","snap buttons","velcro","lace-up","pullover","wrap"
    ]),
    ("style", [
        "minimalist","streetwear","vintage","elegant","sporty","boho",
        "classic","punk","grunge","y2k","preppy","formalwear","business casual"
    ]),
    ("occasion", [
        "casual","formal","office wear","party","wedding guest","outdoor",
        "sportswear","travel","beachwear","evening"
    ]),
    ("season", ["spring","summer","autumn","winter","all-season"]),
    ("body_shape", [
        "pear","apple","hourglass","rectangle","inverted triangle","petite","tall"
    ]),
    ("aesthetic_keywords", [
        "monochrome","color-block","layered","textured","soft fabric","structured",
        "flowy","rigid","urban style","athleisure"
    ]),
    ("detail_features", [
        "pleated","ruched","frilled","ruffled","cut-out","embellished","sequin",
        "beaded","patchwork","distressed","ripped","fringe","pockets","cargo pockets"
    ]),
    ("upcycling_potential", ["low","medium","high","excellent"]),
    ("upcycling_type", [
        "crop-able","dye-friendly","patchwork-ready","embroidery-friendly",
        "cut-and-sew","panel replacement","sleeve modification","repurpose to bag",
        "repurpose to accessory"
    ]),
    ("repairability", [
        "easy to repair","moderate repair","difficult repair"
    ]),
    ("sustainability", [
        "recycled fabric","eco-friendly dye","organic fibers","low environmental impact"
    ]),
    ("visible_accessories", [
        "belt","scarf","hat","cap","beanie","tie","bow tie","handbag","backpack",
        "watch","necklace","earrings","bracelet","glasses","sunglasses"
    ])
])