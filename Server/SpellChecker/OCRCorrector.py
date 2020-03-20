import pkg_resources
import os.path
from symspellpy import SymSpell, Verbosity

class Corrector():
    def __init__(self, language):
       self.dictionaryFileName, self.daysList = self.adjustLanguage(language)
       self.editDistance = 1
       self.sym_spell = SymSpell(max_dictionary_edit_distance=self.editDistance, prefix_length=7)

       self.sym_spell.load_dictionary(self.dictionaryFileName, term_index=0, count_index=1)

    def adjustLanguage(self, language):
        dictionaryPath = os.path.join(os.path.abspath(os.path.dirname(__file__)), "Dictionaries")

        if language == 'English':
            dictionaryPath =  os.path.join(dictionaryPath, "frequency_dictionary_en_82_765.txt")
            daysList = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']
            return dictionaryPath, daysList
        elif language == 'French':
            #dictionaryPath =  dictionaryPath + "lexique_fr.txt"
            dictionaryPath = os.path.join(dictionaryPath, 'lexique_fr.txt')
            daysList = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche']
            return dictionaryPath, daysList

        # Add more languages if needed

    def correct(self, word):
        # max edit distance per lookup
        # (max_edit_distance_lookup <= max_dictionary_edit_distance)
        suggestions = self.sym_spell.lookup(word, Verbosity.CLOSEST,
                                       max_edit_distance=self.editDistance)

        # Verify if suggestions contains a day
        return self.compareList(suggestions)

    def compareList(self, suggestions):
        found = False
        for i in range(len(suggestions)):
            if not found:
                for j in range(len(self.daysList)):
                    if suggestions[i].term == self.daysList[j]:
                        found = True
                        #print(suggestions[i].term)
            else:
                break

        return found

# References
# https://github.com/wolfgarbe/SymSpell
# https://github.com/mammothb/symspellpy
# https://github.com/hermitdave/FrequencyWords


# sudoku solver by teacher
# github.com/MrEliptik/SudokuResolver
