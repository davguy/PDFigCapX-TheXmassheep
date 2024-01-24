import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name="PMMSGD",
    version="0.0.1",
    author="David van Driel, Rouven Koch, Bas ten Haaf",
    author_email="d.vandriel@tudelft.nl",
    description="Automatic tuneup of Poor Man's Majorana sweet spot using a CNN and stochastic gradient descent",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="asdasd",
    packages=setuptools.find_packages(),
    python_requires='>=3.7',
)