import pymorphy2


class LanguageAnalyser:
    def __init__(self):
        self.morph = pymorphy2.MorphAnalyzer()

    def get_normal_form(self, word: str) -> str:
        morph = self.morph.parse(word)
        if len(morph) < 1:
            return ''
        return morph[0].normal_form
