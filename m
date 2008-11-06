From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Thu, 06 Nov 2008 16:47:23 +0100
Subject: [Lustre-devel] [Lustre-shine-commits] SF.net SVN:
	lustre-shine:[43]	branches/0.9-clusterdb/lib/Shine
In-Reply-To: <E1KwzeG-0006Hy-4p@d5vjzd1.ch3.sourceforge.com>
References: <E1KwzeG-0006Hy-4p@d5vjzd1.ch3.sourceforge.com>
Message-ID: <4913118B.4080301@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Quelques petites remarques pas m?chantes :)



 > +(dans Commands/Tune.py)
 > +            tuning = TuningModel(filename="/etc/shine/tuning.conf")

Ne pas oublier que le fichier peut ?tre chang? dans shine.conf :)
tuning = TuningModel(filename=Globals().get_tuning_file())



> +    def __open_file(self):    
> +        """
> +        Function used to open the tuning configuration file specified in the __filename attribute
> +        """
> +        if self.__file != None:
> +            # If the fil is already open raise an exception
> +            raise Exception("File %s is already open" %(self.__filename))
> +        else:
> +            try:    
> +                # Open the file
> +                self.__file = open(self.__filename, "r")
> +            except IOError, e:
> +                    raise Exception("Failed to open the tuning configuration file : %s" %(str(e)))
> +            

- Fait attention ? ne pas lever des exceptions 'Exception', fait une 
sous-classe avec un nom explicit et une petite ligne de doc.
Sinon, un appelant ne peut pas 'catcher' cette erreur l? en particulier 
et laisser remonter les autres. (Ne pas faire non plus 1 class par raise 
dans le code :), certaines sont certainement du meme type :-)


Es-tu sur d'avoir besoin d'un __open_file, __close_file alors qu'ils ne 
sont appel? que dans __load_file ?
Je pense que tu peux simplifier tout ca :)


- Je me demandais, ? propos de la commande Tuning, dans quelle mesure 
vous ?tes oblig? de coller ? la syntaxe de fichiers tuning.conf de 
LustreUtil ?
Ne serait-ce pas l'occasion de la rendre plus user-friendly?



-- 
Aurelien Degremont
CEA
