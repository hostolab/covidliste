<mj-head>
    <mj-preview>This is the inbox preview</mj-preview>
  </mj-head>

<mj-hero
  mode="fixed-height"
  height="46px"
  background-width="272px"
  background-height="46px"
  background-url="https://cloud.githubusercontent.com/assets/1830348/15354890/1442159a-1cf0-11e6-92b1-b861dadf1750.jpg"
  background-color="#2c1a2c"
  padding="0px 0px">

  <mj-hero-content width="100%">

    <mj-text
      padding="20px"
      color="#ffffff"
      font-family="Helvetica"
      align="right"
      font-size="12"
      line-height="45"
      font-weight="900">
      GO TO SPACE
    </mj-text>

    <mj-button href="https://mjml.io/" align="center">
      ORDER YOUR TICKET NOW
    </mj-button>

  </mj-hero-content>

</mj-hero>

<div>
  <h1>Une dose de vaccin est disponible près de chez vous !</h1>

  <p>
    <strong>
    Si vous souhaitez en bénéficier, réservez la dose en confirmant le rendez-vous :
    <br>
      <%= link_to "Réserver mon vaccin", match_url(match_confirmation_token: @match_confirmation_token, source: 'email') %>
    </strong>
  </p>

  <p>
    <strong>Si le lien ne fonctionne pas</strong>, copiez et collez l’adresse suivante dans votre navigateur :
    <br>
    <%= match_url(match_confirmation_token: @match_confirmation_token, source: 'email') %>
  </p>

<%= render "mailer/faq" %>

  <p>
    <strong>Vous ne souhaitez plus être informé de doses disponibles ?</strong>
    <br>
    <strong>
      <%= link_to "Supprimer mon compte", edit_matches_users_url(match_confirmation_token: @match_confirmation_token) %>
    </strong>
  </p>
  <p>
    <strong>Si le lien ne fonctionne pas</strong>, copiez et collez l’adresse suivante dans votre navigateur :
    <br>
    <%= edit_matches_users_url(match_confirmation_token: @match_confirmation_token) %>
  </p>

<%= render "mailer/footer" %>
<%= render "mailer/automatic_message" %>

</div>
