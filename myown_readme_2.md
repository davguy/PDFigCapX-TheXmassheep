## How to run shit

### First important tip:
- This script is meant to be run in a development container. I do not know what this means in detail but the easiest way to get it running is to open the folder in VSCode (make sure you are directly in the folder where the dockerfile is located) and then if you have the DevContainer extension installed it should suggest to you to run the container. 
- Then you are able to run stuff from the VSCode terminal!

### Resolve the relative import nightmare:
- for me the easiest way to resolve it was to just erase the dots infront of the import statements in the utils.py and renderer.py scripts!
-   like so: from utils import natural_sort, pdf2images

### resolve the libraries issue:
- the easiest way is to adjust the devcontainer.json -> there you insert the follwing statement:
    "postCreateCommand": "conda env update -n base -f /workspace/environment.yml"
- this should install the conda environment in the container - but idk really
- to make sure you run the scripts in the correct environment you then do not type python FigCap.py in the terminal but:
-   **/opt/conda/envs/pdfigcapx/bin/python** src/pdfigcapx/FigCap.py


/opt/conda/envs/pdfigcapx/bin/python src/pdfigcapx/FigCap.py

Also change the input and output paths in the FigCap.py script at line 34:
    if __name__ == "__main__":

        input_path = '/workspaces/PDFigCapX/input-pdf'
        output_path = '/workspaces/PDFigCapX/output-pdf'
        xpdf_path = output_path + '/xpdf/'
        log_file = output_path + '/log.text'
        f_log = open(log_file, 'w')
        if not os.path.isdir(xpdf_path):
            os.mkdir(xpdf_path)




## Current ISSUES
- something is wrong with the filepaths but i am not completely sure what the issue is
debugg further

## CURRENT ISSUES RESOLVED!
Finally resolved the insane problem in the FigCap.py script. The issue was that in the original scripped the pdftohtml linux executable from the xpdfReader command line tools was called from a location from which the script didnt have the permission to execute. The solution is as follows:
When you have feshly built up the container. In the terminal navigate to the executables folder. (I have created this folder before and copied the binary exectuable into there). Then from the terminal run the command 

"chmod +x pdftohtml" 

This command gives the permission to run the exectuble.

## NEXT ISSUE
Script cant find the chromdrive because in the pdf_info.py the chromedriver is looked for in the wroing filepath (line 43)
so i did a similar thing to what i did above. Downloaded the chromedriver - (see the dockerfile for reference -> this also confuses me - why do we download all of this but then it is not available?). And copied the chromedriver into the exectuables dir

then ran 

chmod +x chromedriver

NOTE: interestingly i didnt have to rerun those commands when i rebuilt the container

Then you need to change the filpath in the script.

DID not work -> get an error. The issue is potentially that the driver tries to start chrome? IDK

browser = webdriver.Chrome('exectuables/chromedriver')

browser = webdriver.Chrome(ChromeDriverManager(version="114.0.5735.90").install())
Before what I did was to give permissions to the chrome browser as well in the dockerfile by adding:
    && chmod +x usr/bin/google-chrome \
to the dockergile

Matching Chrome browser and chromedriver versions:
From Chat GPT
# Add the Google Chrome repository (replace with the correct repository for your version)
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list

# Update and install the specific Chrome version
RUN apt-get update && apt-get -y install google-chrome-stable=116.0.5845.179


Modified as follows:
&& apt-get update && apt-get -y install google-chrome-stable=114.0.5735.90 \

(Old)
&& apt-get -y update && apt-get -y --no-install-recommends install google-chrome-stable \

also added this:
    && chmod +x usr/bin/google-chrome-stable \


## BIGGER modifications in Dockerfile

Original
    && wget -q -O - --no-check-certificate https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add \
    && echo "deb [arch=amd64]  http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get -y update && apt-get -y --no-install-recommends install google-chrome-stable \
    && chmod +x usr/bin/google-chrome \
    && chmod +x usr/bin/google-chrome-stable \

Modified:

    && wget https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/116.0.5845.96/linux64/chrome-linux64.zip \
    && unzip chrome-linux64.zip \
    && mv chrome /usr/bin/chrome \
    && chown root:root /usr/bin/chrome \
    && chmod +x /usr/bin/chrome \
    && rm chrome-linux64.zip \
    && chmod +x usr/bin/chrome \
  