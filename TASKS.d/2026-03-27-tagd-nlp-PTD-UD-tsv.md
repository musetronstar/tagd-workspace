# TASK

ChatGPT mentioned **Mapping PTB → UD**:

Example:
```
NN   → NOUN
NNS  → NOUN + Number=Plur
NNP  → PROPN
VBD  → VERB + Tense=Past
VBG  → VERB + VerbForm=Ger

```

## Source Files

`assets/penn-treebank-pos.tsv`
`docs/Universal-POS-tags.pdf`

Use the following data sources as canonical - derive solely from them (let me know if anything is missing).

Create a new file `assets/ptd-ud-map.tsv` to contain:
* First three columns of `assets/penn-treebank-pos.tsv`
* Plus a fourth column ("UD") and fill it wil the UD mapping like in the example.
