 return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SizedBox(
          width: 1080,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(
                            context,
                            PageTransition(
                                type: PageTransitionType.leftToRight,
                                child: const WelcomeScreen()));
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(30)),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Color.fromARGB(255, 227, 227, 227),
                          size: 25,
                        ),
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.signup_banner,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleSmall?.color,
                        fontSize: 16,
                      ),
                    ),
                    const LanguageButton(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
                child: Column(
                  children: [
                    //Name textfield
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: InputTextField(
                            controller: nameController,
                            labelText: AppLocalizations.of(context)!.name,
                            obscureText: false,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Flexible(
                          child: InputTextField(
                            controller: surnameController,
                            labelText: AppLocalizations.of(context)!.surname,
                            obscureText: false,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    //Username textfield
                    InputTextField(
                        controller: usernameController,
                        labelText: AppLocalizations.of(context)!.username,
                        obscureText: false),

                    const SizedBox(height: 15),

                    //Email address textfield
                    InputTextField(
                        controller: emailController,
                        labelText: AppLocalizations.of(context)!.email,
                        obscureText: false),

                    const SizedBox(height: 15),

                    //Password textfield
                    TextField(
                      onChanged: (val) => checkPassword(val),
                      controller: passwordController,
                      obscureText: passwordVisible,
                      cursorWidth: 1,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 227, 227, 227),
                          fontSize: 14),
                      decoration: InputDecoration(
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: IconButton(
                            icon: Icon(
                              passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Color.fromARGB(255, 227, 227, 227),
                            ),
                            onPressed: () {
                              setState(
                                () {
                                  passwordVisible = !passwordVisible;
                                },
                              );
                            },
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(17.5))),
                        contentPadding:
                            const EdgeInsets.fromLTRB(15, 15, 15, 15),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).dividerColor, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(17.5)),
                        ),
                        labelText: AppLocalizations.of(context)!.password,
                        labelStyle: const TextStyle(
                            color: Color.fromARGB(255, 138, 138, 138),
                            fontSize: 14),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        fillColor: Theme.of(context).cardColor,
                        filled: true,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        //borderRadius: BorderRadius.circular(  10.0), // Establece el radio de los bordes
                        child: SizedBox(
                          height:
                              4.0, // Ajusta la altura del indicador de progreso según sea necesario
                          child: LinearProgressIndicator(
                            value: strength,
                            backgroundColor: Color.fromARGB(225, 227, 227, 227),
                            color: colorPasswordIndicator,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    //Password textfield
                    PasswordTextField(
                        controller: passControllerVerify,
                        labelText:
                            AppLocalizations.of(context)!.repeat_password,
                        obscureText: true),

                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                          child: Checkbox(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            side: BorderSide(
                                color: Theme.of(context).dividerColor),
                            checkColor:
                                const Color.fromARGB(255, 242, 242, 242),
                            activeColor: const Color.fromARGB(255, 222, 66, 66),
                            value: _isChecked,
                            onChanged: (value) {
                              setState(() {
                                _isChecked = value!;
                              });
                            },
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.i_accept,
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText1?.color,
                              fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      AppLocalizations.of(context)!.terms),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Text(
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                ?.color,
                                          ),
                                          textAlign: TextAlign.justify,
                                          AppLocalizations.of(context)!
                                              .gigaterms,
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: ButtonStyle(
                                        overlayColor:
                                            MaterialStateColor.resolveWith(
                                          (states) => const Color.fromARGB(
                                                  255, 222, 66, 66)
                                              .withOpacity(0.2),
                                        ),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.close,
                                        style: const TextStyle(
                                          color:
                                              Color.fromARGB(255, 222, 66, 66),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: buildRichTextWithEllipsis(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            //Sign up button
                            RedButton(
                              buttonText:
                                  AppLocalizations.of(context)!.signup_button,
                              onTap: signUp,
                            ),
                            const SizedBox(height: 30),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10.5, 0, 10.5, 0),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: GoogleFonts.inter(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                    fontSize: 12,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: AppLocalizations.of(context)!
                                          .explanation1,
                                    ),
                                    TextSpan(
                                      text: AppLocalizations.of(context)!
                                          .explanation2,
                                      style: GoogleFonts.inter(
                                          color: const Color.fromARGB(
                                              255,
                                              204,
                                              49,
                                              49)), // Cambia el color a rojo
                                    ),
                                    TextSpan(
                                      text: AppLocalizations.of(context)!
                                          .explanation3,
                                    ),
                                    TextSpan(
                                      text: AppLocalizations.of(context)!
                                          .explanation4,
                                      style: GoogleFonts.inter(
                                          color: const Color.fromARGB(
                                              255,
                                              204,
                                              49,
                                              49)), // Cambia el color a rojo
                                    ),
                                    TextSpan(
                                      text: AppLocalizations.of(context)!
                                          .explanation5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
