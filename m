From: Peter Braam <Peter.Braam@Sun.COM>
Date: Wed, 24 Sep 2008 10:50:51 +0800
Subject: [Lustre-devel] Doubly indexed tree / changelogs
In-Reply-To: <18648.40197.532872.168033@gargle.gargle.HOWL>
Message-ID: <C4FFCC0B.7DC3%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The idea is ok, but scale may turn out to be different than expected.

There could be a huge amount of filesets containing the word "Bin Laden",
say 100,000 of them.

Would two directories work?


Peter


On 9/23/08 3:38 PM, "Nikita Danilov" <Nikita.Danilov@Sun.COM> wrote:

> Peter Braam writes:
>> Hi Nikita, Nathan -
>> 
>> After some pondering I have come to two conclusions.
>> 
>> To encode filesets, we need a tree that makes two iterations fast:
>> 
>> 1. list all filesets that contain a certain object
>> 2. list all objects in a certain fileset
>> 
>> Is there a doubly indexed tree for this?
> 
> I don't know of a data-structure that provides ready solution for this.
> As Alex pointed out k-d-trees do not fit there (they effectively use a
> key composed of the alternating sequences of bits of the original keys),
> and `geographical trees' that data bases use to store 2-d data use very
> special notion of proximity.
> 
> But, thinking about a fileset as a generalized directory, isn't this the
> same problem as `list all files in directory' and `find all parent
> directories of a file'? It probably makes sense to use the same
> mechanism to deal with directories and filesets.
> 
> Our current solution is to use EA to keep track of all parent
> directories, do you see any problems with applying it to filesets?
> 
>> 
>> Peter
> 
> Nikita.
