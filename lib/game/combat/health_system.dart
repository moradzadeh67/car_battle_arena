class HealthSystem {
  double maxHealth;
  double currentHealth;
  bool isDead = false;

  HealthSystem({required this.maxHealth}) : currentHealth = maxHealth;

  void takeDamage(double amount) {
    if (isDead) return;
    currentHealth -= amount;
    if (currentHealth <= 0) {
      currentHealth = 0;
      isDead = true;
    }
  }

  void heal(double amount) {
    if (isDead) return;
    currentHealth += amount;
    if (currentHealth > maxHealth) currentHealth = maxHealth;
  }

  double get percentage => currentHealth / maxHealth;
}
