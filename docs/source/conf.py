# Configuration file for the Sphinx documentation builder.

# -- Project information

project = 'MartiniGlass'
copyright = '2025, University of Groningen'
author = 'Christopher Brasnett, Siewert-Jan Marrink'

version = '1.0.0'

# -- General configuration

extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.intersphinx',
    'sphinx.ext.mathjax',
    'sphinx.ext.viewcode',
    'sphinx.ext.napoleon',
    'sphinx.ext.autosectionlabel',
    'sphinxcontrib.apidoc',

    'sphinx.ext.duration',
    'sphinx.ext.doctest',
    'sphinx.ext.autosummary',
]

intersphinx_mapping = {
    'python': ('https://docs.python.org/3/', None),
    'sphinx': ('https://www.sphinx-doc.org/en/master/', None),
}
intersphinx_disabled_domains = ['std']

source_suffix = '.rst'

# The master toctree document.
master_doc = 'index'

templates_path = ['_templates']

# -- Options for HTML output

html_theme = 'sphinx_rtd_theme'

# -- Options for EPUB output
epub_show_urls = 'footnote'